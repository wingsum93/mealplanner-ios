//
//  SettingsScreen.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI
struct SettingsScreen: View {
    let isLoggedIn: Bool
    let onLogin: () -> Void
    let onLogout: () -> Void
    @ObservedObject var settingsViewModel: SettingsViewModel

    @State private var pendingAction: SettingsAction?
    @State private var errorMessage: String?

    init(
        isLoggedIn: Bool,
        settingsViewModel: SettingsViewModel,
        onLogin: @escaping () -> Void = {},
        onLogout: @escaping () -> Void = {}
    ) {
        self.isLoggedIn = isLoggedIn
        self.settingsViewModel = settingsViewModel
        self.onLogin = onLogin
        self.onLogout = onLogout
    }
    
    var body: some View {
        List {
            Section("Account") {
                VStack(spacing: 16) {
                    Image("person")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .foregroundColor(.gray.opacity(0.6))

                    Text("Profile Content")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    if isLoggedIn {
                        Button(action: onLogout) {
                            Text("Logout")
                                .fontWeight(.bold)
                                .font(.title3)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(40)
                        }
                    } else {
                        Button(action: onLogin) {
                            Text("Log in")
                                .fontWeight(.bold)
                                .font(.title3)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(40)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }

            Section("Data") {
                Button("Clear cached recipes") {
                    pendingAction = .clearCachedRecipes
                }
                Button("Reset favorites") {
                    pendingAction = .resetFavorites
                }
            }
        }
        .listStyle(.insetGrouped)
        .confirmationDialog(
            "Confirm action",
            isPresented: Binding(get: { pendingAction != nil }, set: { if !$0 { pendingAction = nil } })
        ) {
            Button("Cancel", role: .cancel) { }
            if let action = pendingAction {
                Button(action.confirmButtonTitle, role: .destructive) {
                    handleSettingsAction(action)
                    pendingAction = nil
                }
            }
        } message: {
            Text(pendingAction?.confirmMessage ?? "")
        }
        .alert(
            "Unable to update data",
            isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func handleSettingsAction(_ action: SettingsAction) {
        do {
            switch action {
            case .clearCachedRecipes:
                try settingsViewModel.clearCachedRecipes()
            case .resetFavorites:
                try settingsViewModel.resetFavorites()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    let mockLocal = MockRecipeLocalDataSource()
    SettingsScreen(
        isLoggedIn: false,
        settingsViewModel: SettingsViewModel(localDataSource: mockLocal)
    )
}

private enum SettingsAction: String, Identifiable {
    case clearCachedRecipes
    case resetFavorites

    var id: String { rawValue }

    var confirmButtonTitle: String {
        switch self {
        case .clearCachedRecipes:
            return "Clear cache"
        case .resetFavorites:
            return "Reset favorites"
        }
    }

    var confirmMessage: String {
        switch self {
        case .clearCachedRecipes:
            return "This removes all cached recipes from this device."
        case .resetFavorites:
            return "This clears the favorite flag for all recipes."
        }
    }
}

private struct MockRecipeLocalDataSource: RecipeLocalDataSource {
    func saveRecipe(_ item: RecipeEntity) throws { }
    func getRecipeById(_ id: Int64) throws -> RecipeEntity? { nil }
    func getAllCategories() throws -> [String] { [] }
    func saveAllCategories(_ categories: [String]) throws { }
    func getAllAreas() throws -> [String] { [] }
    func saveAllAreas(_ areas: [String]) throws { }
    func getAllIngredients() throws -> [IngredientEntity] { [] }
    func saveAllIngredients(_ ingredients: [IngredientEntity]) throws { }
    func updateFavorite(id: Int64, isFavorite: Bool) throws { }
    func isFavourite(id: Int64) -> Bool { false }
    func getAllFavoriteRecipes() throws -> [RecipeEntity] { [] }
    func clearCachedRecipes() throws { }
    func resetFavorites() throws { }
}

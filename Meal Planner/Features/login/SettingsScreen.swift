//
//  SettingsScreen.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI
struct SettingsScreen: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    @State private var pendingAction: SettingsAction?

    init(
        settingsViewModel: SettingsViewModel
    ) {
        self.settingsViewModel = settingsViewModel
    }
    
    var body: some View {
        List {
            Section("Data") {
                Button("Clear cached recipes") {
                    pendingAction = .clearCachedRecipes
                }
                Button("Reset favorites") {
                    pendingAction = .resetFavorites
                }
            }

            Section("About") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(appVersionText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Text("Data courtesy of")
                        Link("TheMealDB", destination: theMealDBURL)
                    }
                    .font(.subheadline)

                    if let feedbackURL {
                        Link("Feedback & Support", destination: feedbackURL)
                    }
                    if let privacyPolicyURL {
                        Link("Privacy Policy", destination: privacyPolicyURL)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Open Source") {
                Link("Lottie", destination: lottieURL)
                Link("Kingfisher", destination: kingfisherURL)
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
                    settingsViewModel.onIntent(.perform(action))
                    pendingAction = nil
                }
            }
        } message: {
            Text(pendingAction?.confirmMessage ?? "")
        }
        .alert(
            "Unable to update data",
            isPresented: Binding(
                get: { settingsViewModel.state.errorMessage != nil },
                set: { if !$0 { settingsViewModel.onIntent(.clearError) } }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(settingsViewModel.state.errorMessage ?? "")
        }
    }

    private var appVersionText: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    private var theMealDBURL: URL {
        URL(string: "https://www.themealdb.com") ?? URL(fileURLWithPath: "/")
    }

    private var feedbackURL: URL? {
        URL(string: "mailto:support@mealplanner.app")
    }

    private var privacyPolicyURL: URL? {
        URL(string: "https://www.mealplanner.app/privacy")
    }

    private var lottieURL: URL {
        URL(string: "https://github.com/airbnb/lottie-ios") ?? URL(fileURLWithPath: "/")
    }

    private var kingfisherURL: URL {
        URL(string: "https://github.com/onevcat/Kingfisher") ?? URL(fileURLWithPath: "/")
    }
}

#Preview {
    let mockLocal = MockRecipeLocalDataSource()
    SettingsScreen(
        settingsViewModel: SettingsViewModel(localDataSource: mockLocal)
    )
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

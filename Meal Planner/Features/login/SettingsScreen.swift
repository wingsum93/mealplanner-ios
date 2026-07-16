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
            Section("Storage Overview") {
                SettingsSummaryRow(
                    title: "Saved recipes",
                    value: settingsViewModel.state.summary.savedRecipeCount,
                    systemImage: "fork.knife"
                )
                SettingsSummaryRow(
                    title: "Favorites",
                    value: settingsViewModel.state.summary.favoriteRecipeCount,
                    systemImage: "star.fill"
                )
                SettingsSummaryRow(
                    title: "Categories",
                    value: settingsViewModel.state.summary.cachedCategoryCount,
                    systemImage: "square.grid.2x2"
                )
                SettingsSummaryRow(
                    title: "Areas",
                    value: settingsViewModel.state.summary.cachedAreaCount,
                    systemImage: "map"
                )
                SettingsSummaryRow(
                    title: "Ingredients",
                    value: settingsViewModel.state.summary.cachedIngredientCount,
                    systemImage: "leaf"
                )
            }

            if settingsViewModel.state.statusMessage != nil || settingsViewModel.state.errorMessage != nil {
                Section("Status") {
                    if let statusMessage = settingsViewModel.state.statusMessage {
                        Label(statusMessage, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    if let errorMessage = settingsViewModel.state.errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }

            Section("Data Tools") {
                Button {
                    settingsViewModel.onIntent(.loadSummary)
                } label: {
                    Label("Reload storage overview", systemImage: "arrow.clockwise")
                }

                Button {
                    pendingAction = .clearBrowseCache
                } label: {
                    Label("Clear browse cache", systemImage: "trash")
                }

                Button {
                    pendingAction = .clearLookupCaches
                } label: {
                    Label("Clear lookup caches", systemImage: "tray")
                }

                Button(role: .destructive) {
                    pendingAction = .resetFavorites
                } label: {
                    Label("Reset favorites", systemImage: "star.slash")
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
        .task {
            settingsViewModel.onIntent(.loadSummary)
        }
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
        .onDisappear {
            settingsViewModel.onIntent(.clearStatus)
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
    func getSettingsDataSummary() throws -> SettingsDataSummary {
        SettingsDataSummary(
            savedRecipeCount: 12,
            favoriteRecipeCount: 4,
            cachedCategoryCount: 8,
            cachedAreaCount: 6,
            cachedIngredientCount: 20
        )
    }
    func clearBrowseCachePreservingFavorites() throws { }
    func clearLookupCaches() throws { }
    func resetFavorites() throws { }
}

private struct SettingsSummaryRow: View {
    let title: String
    let value: Int
    let systemImage: String

    var body: some View {
        HStack {
            Label(title, systemImage: systemImage)
            Spacer()
            Text(value.formatted())
                .font(.headline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

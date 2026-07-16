//
//  ProfileScreen.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI

struct ProfileScreen:View{
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    init(
        settingsViewModel: SettingsViewModel
    ) {
        self.settingsViewModel = settingsViewModel
    }
    
    // MARK: - Convenience initializer for preview
    init() {
        let mockSettingsVM = SettingsViewModel(localDataSource: MockRecipeLocalDataSource())
        self.init(settingsViewModel: mockSettingsVM)
    }
    
    var body: some View{
        SettingsScreen(
            settingsViewModel: settingsViewModel
        )
    }
}

#Preview {
    ProfileScreen()
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
    func getSettingsDataSummary() throws -> SettingsDataSummary { SettingsDataSummary() }
    func clearBrowseCachePreservingFavorites() throws { }
    func clearLookupCaches() throws { }
    func resetFavorites() throws { }
}

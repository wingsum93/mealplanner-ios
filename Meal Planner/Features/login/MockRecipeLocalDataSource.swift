//
//  MockRecipeLocalDataSource.swift
//  Meal Planner
//
//  Created by eric ho on 22/9/2026.
//

#if DEBUG
import Foundation

struct MockRecipeLocalDataSource: RecipeLocalDataSource {
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
#endif

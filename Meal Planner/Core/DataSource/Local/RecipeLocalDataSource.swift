//
//  RecipeLocalDataSource.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import Foundation

protocol RecipeLocalDataSource{
    func saveRecipe(_ item: RecipeEntity) throws
    func getRecipeById(_ id: Int64) throws -> RecipeEntity?
    
    func getAllCategories() throws -> [String]
    func saveAllCategories(_ categories: [String]) throws
    
    func getAllAreas() throws -> [String]
    func saveAllAreas(_ areas: [String]) throws
    
    func getAllIngredients() throws -> [IngredientEntity]
    func saveAllIngredients(_ ingredients: [IngredientEntity]) throws
    
    // favourite
    func updateFavorite(id: Int64, isFavorite: Bool) throws
    func isFavourite(id:Int64)-> Bool
    func getAllFavoriteRecipes() throws -> [RecipeEntity]

    // my list (id-only rows, unique per mealId + type)
    func upsertListEntry(mealId: Int64, type: RecipeListType, at date: Date) throws
    func removeListEntry(mealId: Int64, type: RecipeListType) throws
    func isInList(mealId: Int64, type: RecipeListType) -> Bool
    func getListEntries(type: RecipeListType) throws -> [RecipeListEntry]
    func getListCount(type: RecipeListType) throws -> Int
    func resetList(type: RecipeListType) throws
    func allListMealIds() throws -> Set<Int64>

    // settings
    func getSettingsDataSummary() throws -> SettingsDataSummary
    func clearBrowseCachePreservingFavorites() throws
    func clearLookupCaches() throws
    func resetFavorites() throws
}

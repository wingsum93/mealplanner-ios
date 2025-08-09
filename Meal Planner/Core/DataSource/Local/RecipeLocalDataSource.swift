//
//  RecipeLocalDataSource.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

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
    func getAllFavoriteRecipes() throws -> [RecipeEntity]
}

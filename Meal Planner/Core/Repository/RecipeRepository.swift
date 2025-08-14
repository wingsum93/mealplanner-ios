//
//  RecipeRepository.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

protocol RecipeRepository {
    func getAllIngredients() async throws -> [Ingredient]
    func getAllCategory() async throws -> [String]
    func getAllArea() async throws -> [String]
    func getBySingleIngredient(_ name: String) async throws -> [RecipeItem]
    func getByCategory(_ category: String) async throws -> [RecipeItem]
    func getByArea(_ area: String) async throws -> [RecipeItem]
    func searchByName(_ keyword: String) async throws -> [RecipeItem]
    func getRecipeDetail(id: String) async throws -> RecipeItem
    func getRandomRecipe() async throws -> RecipeItem
    func getRandom10Recipe() async throws -> [RecipeItem]
    
    func updateFavorite(id: Int64, isFavorite: Bool) throws
    func isFavourite(id:Int64)-> Bool
    func getAllFavoriteRecipes() throws -> [RecipeItem]
}

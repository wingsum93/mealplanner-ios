//
//  RecipeRepository.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

protocol RecipeRepository {
    func getAllIngredients() async throws -> [RecipeItem]
    func getAllCategory() async throws -> [RecipeItem]
    func getAllArea() async throws -> [RecipeItem]
    func getBySingleIngredient(_ name: String) async throws -> [RecipeItem]
    func getByCategory(_ category: String) async throws -> [RecipeItem]
    func searchByName(_ keyword: String) async throws -> [RecipeItem]
    func getRecipeDetail(id: String) async throws -> RecipeItem
    func getRandomRecipe() async throws -> RecipeItem
}

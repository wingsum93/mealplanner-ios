//
//  RecipeRemoteDataSource.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

protocol RecipeRemoteDataSource{
    func getAllIngredients() async throws -> [IngredientDto]
    func getAllCategory() async throws -> [String]
    func getAllArea() async throws -> [String]
    func getBySingleIngredient(_ ingredient: String) async throws -> [RecipeItemDto]
    func getByCategory(_ category: String) async throws -> [RecipeItemDto]
    func getByArea(_ area: String) async throws -> [RecipeItemDto]
    func searchByName(_ keyword: String) async throws -> [RecipeItemDto]
    func getRecipeDetail(id: String) async throws -> RecipeItemDto?
    func getRandomRecipe() async throws -> RecipeItemDto
    func getRandom10Recipe() async throws -> [RecipeItemDto]
}

//
//  DummyRecipeRepository.swift
//  Meal Planner
//
//  Created by eric ho on 5/8/2025.
//

import Foundation

final class DummyRecipeRepository: RecipeRepository {
    func getByArea(_ area: String) async throws -> [RecipeItem] {
        return [sampleRecipeItem(id: 123, title: "\(area) pizza")]
    }
    
    func getRandom10Recipe() async throws -> [RecipeItem] {
        return []
    }
    
    
    func getAllIngredients() async throws -> [Ingredient] {
        return [
            Ingredient(id: 1, name: "Beef", descriptionText: "Rich red meat", type: "Meat"),
            Ingredient(id: 2, name: "Garlic", descriptionText: "Flavor enhancer", type: "Vegetable")
        ]
    }
    
    func getAllCategory() async throws -> [String] {
        return ["Beef", "Dessert", "Seafood"]
    }
    
    func getAllArea() async throws -> [String] {
        return ["American", "British", "Japanese"]
    }
    
    func getBySingleIngredient(_ name: String) async throws -> [RecipeItem] {
        return [sampleRecipeItem(id: 101, title: "\(name) Stew")]
    }
    
    func getByCategory(_ category: String) async throws -> [RecipeItem] {
        return [sampleRecipeItem(id: 102, title: "\(category) Delight")]
    }
    
    func searchByName(_ keyword: String) async throws -> [RecipeItem] {
        return [sampleRecipeItem(id: 103, title: "Search: \(keyword)")]
    }
    
    func getRecipeDetail(id: String) async throws -> RecipeItem {
        return sampleRecipeItem(id: Int64(id) ?? 999, title: "Detailed Recipe")
    }
    
    func getRandomRecipe() async throws -> RecipeItem {
        return sampleRecipeItem(id: 100, title: "Random Pick")
    }
    
    func updateFavorite(id: Int64, isFavorite: Bool) throws {
        // No-op in dummy
    }
    
    func getAllFavoriteRecipes() throws -> [RecipeItem] {
        return [sampleRecipeItem(id: 200, title: "Fav Recipe")]
    }
    
    
    // MARK: - Sample Recipe Generator
    
    private func sampleRecipeItem(id: Int64, title: String) -> RecipeItem {
        RecipeItem(
            id: id,
            title: title,
            description: "A delicious mock recipe.",
            category: "MockCategory",
            area: "MockArea",
            imageUrl: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg",
            youtubeLink: "https://youtube.com/mockvideo",
            ingredients: ["MockIngredient: 1 cup", "Salt: 1 tsp"],
            instructions: ["Step 1", "Step 2"],
            isFavorite: false,
            rating: 4)
    }
}

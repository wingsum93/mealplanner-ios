//
//  DefaultRecipeRepositoryImpl.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

class RecipeRepositoryImpl: RecipeRepository{
    private let remote: RecipeRemoteDataSource
    private let local: RecipeLocalDataSource
    
    init(remote: RecipeRemoteDataSource, local: RecipeLocalDataSource) {
        self.remote = remote
        self.local = local
    }
    
    func getAllIngredients() async throws -> [RecipeItem] {
        fatalError("TODO: implement this function")
    }
    
    func getAllCategory() async throws -> [RecipeItem] {
        fatalError("TODO: implement this function")
    }
    
    func getAllArea() async throws -> [RecipeItem] {
        fatalError("TODO: implement this function")
    }
    
    func getBySingleIngredient(_ name: String) async throws -> [RecipeItem] {
        fatalError("TODO: implement this function")
    }
    
    func getByCategory(_ category: String) async throws -> [RecipeItem] {
        fatalError("TODO: implement this function")
    }
    
    func searchByName(_ keyword: String) async throws -> [RecipeItem] {
        fatalError("TODO: implement this function")
    }
    
    func getRecipeDetail(id: String) async throws -> RecipeItem {
        fatalError("TODO: implement this function")
    }
    
    func getRandomRecipe() async throws -> RecipeItem {
        fatalError("TODO: implement this function")
    }
    
    
}

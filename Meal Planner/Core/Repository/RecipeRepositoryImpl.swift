//
//  DefaultRecipeRepositoryImpl.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import Foundation

class RecipeRepositoryImpl: RecipeRepository{
    private let remote: RecipeRemoteDataSource
    private let local: RecipeLocalDataSource
    
    init(remote: RecipeRemoteDataSource, local: RecipeLocalDataSource) {
        self.remote = remote
        self.local = local
    }

    // MARK: - Cached Methods
    
    func getAllCategory() async throws -> [String] {
        if let cached = try? local.getAllCategories(), !cached.isEmpty {
            return cached
        }
        let result = try await remote.getAllCategory()
        try local.saveAllCategories(result)
        return result
    }
    
    func getAllArea() async throws -> [String] {
        if let cached = try? local.getAllAreas(), !cached.isEmpty {
            return cached
        }
        let result = try await remote.getAllArea()
        try local.saveAllAreas(result)
        return result
    }
    func getAllIngredients() async throws -> [Ingredient] {
        let cachedEntities = try local.getAllIngredients()
        if !cachedEntities.isEmpty {
            return cachedEntities.map { $0.toDomain() }
        }
        
        let dtos = try await remote.getAllIngredients()
        let domains = dtos.compactMap { $0.toDomain() }
        try local.saveAllIngredients(domains.map { $0.toEntity() })
        return domains
    }
    
    // MARK: - Direct Remote Methods
    
    func getBySingleIngredient(_ name: String) async throws -> [RecipeItem] {
        return try await remote.getBySingleIngredient(name).map{$0.toDomain()}
    }
    
    func getByCategory(_ category: String) async throws -> [RecipeItem] {
        return try await remote.getByCategory(category).map{$0.toDomain()}
    }
    
    func searchByName(_ keyword: String) async throws -> [RecipeItem] {
        return try await remote.searchByName(keyword).map{$0.toDomain()}
    }
    
    func getRecipeDetail(id: String) async throws -> RecipeItem {
        guard let item = try await remote.getRecipeDetail(id: id) else {
            throw URLError(.badServerResponse)
        }
        return item.toDomain()
    }
    
    func getRandomRecipe() async throws -> RecipeItem {
        return try await remote.getRandomRecipe().toDomain()
    }
    
    func getRandom10Recipe() async throws -> [RecipeItem]{
        return try await remote.getRandom10Recipe().map{res in res.toDomain()}
    }
    
    func updateFavorite(id: Int64, isFavorite: Bool) throws {
        try local.updateFavorite(id: id, isFavorite: isFavorite)
    }

    func getAllFavoriteRecipes() throws -> [RecipeItem] {
        let entities = try local.getAllFavoriteRecipes()
        return entities.map { $0.toDomain() }
    }
    
}

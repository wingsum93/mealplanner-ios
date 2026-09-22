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
        let myResult = result.getAppSupportArea()
        try local.saveAllAreas(myResult)
        return myResult
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
    
    func getByArea(_ area: String) async throws -> [RecipeItem]{
        return try await remote.getByArea(area).map{$0.toDomain()}
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

    func saveRecipe(_ item: RecipeItem) throws {
        if try local.getRecipeById(item.id) == nil {
            try local.saveRecipe(item.toEntity())
        }
    }
    
    func updateFavorite(id: Int64, isFavorite: Bool) throws {
        try local.updateFavorite(id: id, isFavorite: isFavorite)
    }
    
    func isFavourite(id: Int64) -> Bool {
        return local.isFavourite(id: id)
    }
    
    func getAllFavoriteRecipes() throws -> [RecipeItem] {
        let entities = try local.getAllFavoriteRecipes()
        return entities.map { $0.toDomain() }
    }

    // MARK: - My List

    func setRecipeInList(_ item: RecipeItem, type: RecipeListType, isIncluded: Bool) throws {
        if isIncluded {
            // Cache the full payload when available so the list can render
            // offline; summaries are skipped to avoid poisoning the cache.
            if !item.ingredients.isEmpty || !item.instructions.isEmpty {
                try saveRecipe(item)
            }
            try local.upsertListEntry(mealId: item.id, type: type, at: Date())
        } else {
            try local.removeListEntry(mealId: item.id, type: type)
        }
    }

    func isRecipeInList(id: Int64, type: RecipeListType) -> Bool {
        local.isInList(mealId: id, type: type)
    }

    func getRecipesInList(type: RecipeListType) async throws -> [RecipeItem] {
        let entries = try local.getListEntries(type: type)
        guard !entries.isEmpty else { return [] }

        let favouriteIds = Set((try? local.getListEntries(type: .favourite))?.map(\.mealId) ?? [])

        var items: [RecipeItem] = []
        for entry in entries {
            if let entity = try local.getRecipeById(entry.mealId) {
                items.append(decorate(entity.toDomain(), favouriteIds: favouriteIds))
                continue
            }
            // Fallback: the payload was never cached (e.g. cache cleared).
            if let detail = try? await getRecipeDetail(id: String(entry.mealId)) {
                try? local.saveRecipe(detail.toEntity())
                items.append(decorate(detail, favouriteIds: favouriteIds))
            }
        }
        return items
    }

    func recordRecipeView(id: Int64) throws {
        try local.upsertListEntry(mealId: id, type: .viewed, at: Date())
    }

    func resetList(type: RecipeListType) throws {
        try local.resetList(type: type)
    }

    func getListCount(type: RecipeListType) throws -> Int {
        try local.getListCount(type: type)
    }

    private func decorate(
        _ item: RecipeItem,
        favouriteIds: Set<Int64>
    ) -> RecipeItem {
        item.with(isFavorite: favouriteIds.contains(item.id))
    }
}

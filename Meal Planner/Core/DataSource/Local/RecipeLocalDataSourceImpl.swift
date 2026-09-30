//
//  RecipeLocalDataSourceImpl.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//
import SwiftData
import Foundation

public final class RecipeLocalDataSourceImpl: RecipeLocalDataSource {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func saveRecipe(_ item: RecipeEntity) throws {
        context.insert(item)
        try context.save()
    }
    
    func getRecipeById(_ id: Int64) throws -> RecipeEntity? {
        let descriptor = FetchDescriptor<RecipeEntity>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }
    
    // MARK: - Caching Text Lists
    
    private let categoryKey = "cached_categories"
    private let areaKey = "cached_areas"
    
    func saveAllCategories(_ categories: [String]) throws {
        UserDefaults.standard.set(categories, forKey: categoryKey)
    }
    
    func getAllCategories() throws -> [String] {
        return UserDefaults.standard.stringArray(forKey: categoryKey) ?? []
    }
    
    func saveAllAreas(_ areas: [String]) throws {
        UserDefaults.standard.set(areas, forKey: areaKey)
    }
    
    func getAllAreas() throws -> [String] {
        return UserDefaults.standard.stringArray(forKey: areaKey) ?? []
    }
    
    func saveAllIngredients(_ ingredients: [IngredientEntity]) throws {
        // Optional: Clear old if needed
        for ingredient in ingredients {
            context.insert(ingredient)
        }
        try context.save()
    }
    
    func getAllIngredients() throws -> [IngredientEntity] {
        let descriptor = FetchDescriptor<IngredientEntity>()
        return try context.fetch(descriptor)
    }
    
    
    func updateFavorite(id: Int64, isFavorite: Bool) throws {
        if isFavorite {
            try upsertListEntry(mealId: id, type: .favourite, at: Date())
        } else {
            try removeListEntry(mealId: id, type: .favourite)
        }
    }
    
    func isFavourite(id: Int64) -> Bool {
        isInList(mealId: id, type: .favourite)
    }

    func getAllFavoriteRecipes() throws -> [RecipeEntity] {
        let entries = try getListEntries(type: .favourite)
        let ids = entries.map(\.mealId)
        guard !ids.isEmpty else { return [] }
        let descriptor = FetchDescriptor<RecipeEntity>(
            predicate: #Predicate { ids.contains($0.id) }
        )
        let entities = try context.fetch(descriptor)
        let byId = Dictionary(uniqueKeysWithValues: entities.map { ($0.id, $0) })
        return ids.compactMap { byId[$0] }
    }

    // MARK: - My List Entries

    func upsertListEntry(mealId: Int64, type: RecipeListType, at date: Date) throws {
        let raw = type.rawValue
        let descriptor = FetchDescriptor<RecipeListEntry>(
            predicate: #Predicate { $0.mealId == mealId && $0.typeRaw == raw }
        )
        if let existing = try context.fetch(descriptor).first {
            existing.updatedAt = date
        } else {
            context.insert(RecipeListEntry(mealId: mealId, type: type, updatedAt: date))
        }
        try context.save()
    }

    func removeListEntry(mealId: Int64, type: RecipeListType) throws {
        let raw = type.rawValue
        let descriptor = FetchDescriptor<RecipeListEntry>(
            predicate: #Predicate { $0.mealId == mealId && $0.typeRaw == raw }
        )
        try context.fetch(descriptor).forEach { context.delete($0) }
        try context.save()
    }

    func isInList(mealId: Int64, type: RecipeListType) -> Bool {
        let raw = type.rawValue
        let descriptor = FetchDescriptor<RecipeListEntry>(
            predicate: #Predicate { $0.mealId == mealId && $0.typeRaw == raw }
        )
        do {
            return try context.fetchCount(descriptor) > 0
        } catch {
            return false
        }
    }

    func getListEntries(type: RecipeListType) throws -> [RecipeListEntry] {
        let raw = type.rawValue
        let descriptor = FetchDescriptor<RecipeListEntry>(
            predicate: #Predicate { $0.typeRaw == raw },
            sortBy: [SortDescriptor(\RecipeListEntry.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func getListCount(type: RecipeListType) throws -> Int {
        let raw = type.rawValue
        let descriptor = FetchDescriptor<RecipeListEntry>(
            predicate: #Predicate { $0.typeRaw == raw }
        )
        return try context.fetchCount(descriptor)
    }

    func resetList(type: RecipeListType) throws {
        let raw = type.rawValue
        let descriptor = FetchDescriptor<RecipeListEntry>(
            predicate: #Predicate { $0.typeRaw == raw }
        )
        try context.fetch(descriptor).forEach { context.delete($0) }
        try context.save()
    }

    func allListMealIds() throws -> Set<Int64> {
        let entries = try context.fetch(FetchDescriptor<RecipeListEntry>())
        return Set(entries.map(\.mealId))
    }

    func getSettingsDataSummary() throws -> SettingsDataSummary {
        let descriptor = FetchDescriptor<RecipeEntity>()
        let ingredientDescriptor = FetchDescriptor<IngredientEntity>()

        return SettingsDataSummary(
            savedRecipeCount: try context.fetchCount(descriptor),
            favoriteRecipeCount: try getListCount(type: .favourite),
            masteredRecipeCount: try getListCount(type: .mastered),
            cachedCategoryCount: (try getAllCategories()).count,
            cachedAreaCount: (try getAllAreas()).count,
            cachedIngredientCount: try context.fetchCount(ingredientDescriptor)
        )
    }

    func clearBrowseCachePreservingFavorites() throws {
        let keepIds = try allListMealIds()
        let recipes = try context.fetch(FetchDescriptor<RecipeEntity>())
        recipes
            .filter { !keepIds.contains($0.id) }
            .forEach { context.delete($0) }
        try context.save()
    }

    func clearLookupCaches() throws {
        UserDefaults.standard.removeObject(forKey: categoryKey)
        UserDefaults.standard.removeObject(forKey: areaKey)

        let descriptor = FetchDescriptor<IngredientEntity>()
        let ingredients = try context.fetch(descriptor)
        ingredients.forEach { context.delete($0) }
        try context.save()
    }

    func resetFavorites() throws {
        try resetList(type: .favourite)
    }
}

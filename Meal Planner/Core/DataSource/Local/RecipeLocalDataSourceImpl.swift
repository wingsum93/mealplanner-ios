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
        let descriptor = FetchDescriptor<RecipeEntity>(
            predicate: #Predicate { $0.id == id }
        )
        if let entity = try context.fetch(descriptor).first {
            entity.isFavorite = isFavorite
            try context.save()
        }
    }

    func getAllFavoriteRecipes() throws -> [RecipeEntity] {
        let descriptor = FetchDescriptor<RecipeEntity>(
            predicate: #Predicate { $0.isFavorite == true }
        )
        return try context.fetch(descriptor)
    }
}

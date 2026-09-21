//
//  TestSupport.swift
//  Meal PlannerTests
//
//  Created by Codex on 15/7/2026.
//

import Foundation

func waitUntil(
    timeout: Duration = .seconds(1),
    pollingInterval: Duration = .milliseconds(1),
    condition: @MainActor @escaping () -> Bool
) async throws {
    let deadline = ContinuousClock.now + timeout
    while ContinuousClock.now < deadline {
        if await condition() {
            return
        }
        try await Task.sleep(for: pollingInterval)
    }
    if await condition() {
        return
    }
    throw TestError.timedOut
}

final class SearchRaceRecipeRepository: RecipeRepository {
    private let delayedSlowSearch: Bool

    init(delayedSlowSearch: Bool = false) {
        self.delayedSlowSearch = delayedSlowSearch
    }

    func searchByName(_ keyword: String) async throws -> [RecipeItem] {
        if delayedSlowSearch && keyword == "slow" {
            await delayIgnoringCancellation(seconds: 0.35)
        }

        return [recipe(id: keyword == "slow" ? 1 : 2, title: "\(keyword) result")]
    }

    func getAllIngredients() async throws -> [Ingredient] { [] }
    func getAllCategory() async throws -> [String] { [] }
    func getAllArea() async throws -> [String] { [] }
    func getBySingleIngredient(_ name: String) async throws -> [RecipeItem] { [] }
    func getByCategory(_ category: String) async throws -> [RecipeItem] { [] }
    func getByArea(_ area: String) async throws -> [RecipeItem] { [] }
    func getRecipeDetail(id: String) async throws -> RecipeItem { recipe(id: Int64(id) ?? 0, title: "detail") }
    func getRandomRecipe() async throws -> RecipeItem { recipe(id: 99, title: "random") }
    func getRandom10Recipe() async throws -> [RecipeItem] { [] }
    func saveRecipe(_ item: RecipeItem) throws {}
    func updateFavorite(id: Int64, isFavorite: Bool) throws {}
    func isFavourite(id: Int64) -> Bool { false }
    func getAllFavoriteRecipes() throws -> [RecipeItem] { [] }

    private func delayIgnoringCancellation(seconds: TimeInterval) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + seconds) {
                continuation.resume()
            }
        }
    }

    private func recipe(id: Int64, title: String) -> RecipeItem {
        makeRecipe(id: id, title: title)
    }
}

final class DebouncedSearchRecipeRepository: RecipeRepository {
    private let queue = DispatchQueue(label: "DebouncedSearchRecipeRepository.queue")
    private var _searchedKeywords: [String] = []

    var searchedKeywords: [String] {
        queue.sync { _searchedKeywords }
    }

    func searchByName(_ keyword: String) async throws -> [RecipeItem] {
        let callCount = queue.sync {
            _searchedKeywords.append(keyword)
            return _searchedKeywords.count
        }

        return [makeRecipe(id: Int64(callCount), title: "\(keyword) result")]
    }

    func getAllIngredients() async throws -> [Ingredient] { [] }
    func getAllCategory() async throws -> [String] { [] }
    func getAllArea() async throws -> [String] { [] }
    func getBySingleIngredient(_ name: String) async throws -> [RecipeItem] { [] }
    func getByCategory(_ category: String) async throws -> [RecipeItem] { [] }
    func getByArea(_ area: String) async throws -> [RecipeItem] { [] }
    func getRecipeDetail(id: String) async throws -> RecipeItem { makeRecipe(id: Int64(id) ?? 0, title: "detail") }
    func getRandomRecipe() async throws -> RecipeItem { makeRecipe(id: 99, title: "random") }
    func getRandom10Recipe() async throws -> [RecipeItem] { [] }
    func saveRecipe(_ item: RecipeItem) throws {}
    func updateFavorite(id: Int64, isFavorite: Bool) throws {}
    func isFavourite(id: Int64) -> Bool { false }
    func getAllFavoriteRecipes() throws -> [RecipeItem] { [] }
}

final class FavoriteRecipeRepository: RecipeRepository {
    var favorites: [RecipeItem]
    var shouldFailLoad = false
    var shouldFailUpdate = false

    init(favorites: [RecipeItem] = []) {
        self.favorites = favorites
    }

    func updateFavorite(id: Int64, isFavorite: Bool) throws {
        if shouldFailUpdate {
            throw TestError.expected
        }

        if let index = favorites.firstIndex(where: { $0.id == id }) {
            favorites[index] = favorites[index].with(isFavorite: isFavorite)
            if !isFavorite {
                favorites.remove(at: index)
            }
        }
    }

    func saveRecipe(_ item: RecipeItem) throws {
        if let index = favorites.firstIndex(where: { $0.id == item.id }) {
            favorites[index] = item
        } else {
            favorites.append(item)
        }
    }

    func getAllFavoriteRecipes() throws -> [RecipeItem] {
        if shouldFailLoad {
            throw TestError.expected
        }

        return favorites.filter(\.isFavorite)
    }

    func getAllIngredients() async throws -> [Ingredient] { [] }
    func getAllCategory() async throws -> [String] { [] }
    func getAllArea() async throws -> [String] { [] }
    func getBySingleIngredient(_ name: String) async throws -> [RecipeItem] { [] }
    func getByCategory(_ category: String) async throws -> [RecipeItem] { [] }
    func getByArea(_ area: String) async throws -> [RecipeItem] { [] }
    func searchByName(_ keyword: String) async throws -> [RecipeItem] { [] }
    func getRecipeDetail(id: String) async throws -> RecipeItem { makeRecipe(id: Int64(id) ?? 0, title: "detail") }
    func getRandomRecipe() async throws -> RecipeItem { makeRecipe(id: 99, title: "random") }
    func getRandom10Recipe() async throws -> [RecipeItem] { [] }
    func isFavourite(id: Int64) -> Bool { favorites.contains { $0.id == id && $0.isFavorite } }
}

final class SettingsLocalDataSourceSpy: RecipeLocalDataSource {
    var error: Error?
    var summary = SettingsDataSummary(
        savedRecipeCount: 3,
        favoriteRecipeCount: 1,
        cachedCategoryCount: 2,
        cachedAreaCount: 4,
        cachedIngredientCount: 5
    )
    private(set) var summaryCallCount = 0
    private(set) var clearBrowseCacheCallCount = 0
    private(set) var clearLookupCachesCallCount = 0
    private(set) var resetFavoritesCallCount = 0

    func getSettingsDataSummary() throws -> SettingsDataSummary {
        summaryCallCount += 1
        if let error { throw error }
        return summary
    }

    func clearBrowseCachePreservingFavorites() throws {
        clearBrowseCacheCallCount += 1
        if let error { throw error }
        summary.savedRecipeCount = summary.favoriteRecipeCount
    }

    func clearLookupCaches() throws {
        clearLookupCachesCallCount += 1
        if let error { throw error }
        summary.cachedCategoryCount = 0
        summary.cachedAreaCount = 0
        summary.cachedIngredientCount = 0
    }

    func resetFavorites() throws {
        resetFavoritesCallCount += 1
        if let error { throw error }
        summary.favoriteRecipeCount = 0
    }

    func saveRecipe(_ item: RecipeEntity) throws {}
    func getRecipeById(_ id: Int64) throws -> RecipeEntity? { nil }
    func getAllCategories() throws -> [String] { [] }
    func saveAllCategories(_ categories: [String]) throws {}
    func getAllAreas() throws -> [String] { [] }
    func saveAllAreas(_ areas: [String]) throws {}
    func getAllIngredients() throws -> [IngredientEntity] { [] }
    func saveAllIngredients(_ ingredients: [IngredientEntity]) throws {}
    func updateFavorite(id: Int64, isFavorite: Bool) throws {}
    func isFavourite(id: Int64) -> Bool { false }
    func getAllFavoriteRecipes() throws -> [RecipeEntity] { [] }
}

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

    func saveRecipe(_ item: RecipeItem) throws {}

    func updateFavorite(id: Int64, isFavorite: Bool) throws {}

    func isFavourite(id: Int64) -> Bool {
        return false
    }

    func getAllFavoriteRecipes() throws -> [RecipeItem] {
        return [sampleRecipeItem(id: 200, title: "Fav Recipe")]
    }

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
            measures: [],
            instructions: ["Step 1", "Step 2"],
            tags: [],
            isFavorite: false)
    }
}

enum TestError: LocalizedError {
    case expected
    case timedOut

    var errorDescription: String? {
        switch self {
        case .expected:
            return "Expected failure"
        case .timedOut:
            return "Timed out waiting for test condition"
        }
    }
}

extension RecipeItem {
    func with(isFavorite: Bool) -> RecipeItem {
        RecipeItem(
            id: id,
            title: title,
            description: description,
            category: category,
            area: area,
            imageUrl: imageUrl,
            youtubeLink: youtubeLink,
            ingredients: ingredients,
            measures: measures,
            instructions: instructions,
            tags: tags,
            isFavorite: isFavorite
        )
    }
}

func makeRecipe(
    id: Int64,
    title: String,
    area: String = "Area",
    category: String = "Category",
    isFavorite: Bool = false
) -> RecipeItem {
    RecipeItem(
        id: id,
        title: title,
        description: "Description",
        category: category,
        area: area,
        imageUrl: "",
        youtubeLink: "",
        ingredients: [],
        measures: [],
        instructions: [],
        tags: [],
        isFavorite: isFavorite
    )
}

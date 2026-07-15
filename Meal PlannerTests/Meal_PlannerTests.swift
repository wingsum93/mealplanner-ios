//
//  Meal_PlannerTests.swift
//  Meal PlannerTests
//
//  Created by eric ho on 3/8/2025.
//

import Testing
import Foundation
@testable import Meal_Planner

struct Meal_PlannerTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @MainActor
    @Test func staleSearchCompletionDoesNotOverwriteCurrentQuery() async throws {
        let repository = SearchRaceRecipeRepository()
        let viewModel = FeatureViewModel(repository: repository)

        viewModel.onIntent(.updateQuery("slow"))
        viewModel.onIntent(.performSearch)

        try await Task.sleep(nanoseconds: 50_000_000)

        viewModel.onIntent(.updateQuery("fast"))
        viewModel.onIntent(.performSearch)

        try await Task.sleep(nanoseconds: 800_000_000)

        #expect(viewModel.state.search.query == "fast")
        #expect(viewModel.state.search.results.map(\.name) == ["fast result"])
    }
}

private final class SearchRaceRecipeRepository: RecipeRepository {
    func searchByName(_ keyword: String) async throws -> [RecipeItem] {
        if keyword == "slow" {
            await delayIgnoringCancellation(seconds: 0.35)
        } else {
            await delayIgnoringCancellation(seconds: 0.01)
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
        RecipeItem(
            id: id,
            title: title,
            description: "Description",
            category: "Category",
            area: "Area",
            imageUrl: "",
            youtubeLink: "",
            ingredients: [],
            measures: [],
            instructions: [],
            tags: [],
            isFavorite: false
        )
    }
}

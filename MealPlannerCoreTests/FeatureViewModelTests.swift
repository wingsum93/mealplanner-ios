//
//  FeatureViewModelTests.swift
//  Meal PlannerTests
//
//  Created by Codex on 15/7/2026.
//

import Testing

struct FeatureViewModelTests {

    @MainActor
    @Test func staleSearchCompletionDoesNotOverwriteCurrentQuery() async throws {
        let repository = SearchRaceRecipeRepository(delayedSlowSearch: true)
        let viewModel = FeatureViewModel(repository: repository, searchDebounceDelay: 0)

        viewModel.onIntent(.updateQuery("slow"))
        viewModel.onIntent(.performSearch)

        try await waitUntil {
            viewModel.state.search.phase == .loading
        }

        viewModel.onIntent(.updateQuery("fast"))
        viewModel.onIntent(.performSearch)

        try await waitUntil {
            viewModel.state.search.results.map(\.name) == ["fast result"]
        }

        #expect(viewModel.state.search.query == "fast")
        #expect(viewModel.state.search.results.map(\.name) == ["fast result"])
    }

    @MainActor
    @Test func emptySearchQueryResetsSearchState() async throws {
        let viewModel = FeatureViewModel(repository: SearchRaceRecipeRepository(), searchDebounceDelay: 0)

        viewModel.onIntent(.updateQuery("chicken"))
        viewModel.onIntent(.performSearch)
        try await waitUntil {
            viewModel.state.search.results.map(\.name) == ["chicken result"]
        }

        viewModel.onIntent(.updateQuery(""))
        viewModel.onIntent(.performSearch)

        #expect(viewModel.state.search.query == "")
        #expect(viewModel.state.search.phase == .idle)
        #expect(viewModel.state.search.results.isEmpty)
    }

    @MainActor
    @Test func oneCharacterSearchQueryDoesNotCallRepository() async throws {
        let repository = DebouncedSearchRecipeRepository()
        let viewModel = FeatureViewModel(repository: repository, searchDebounceDelay: 0)

        viewModel.onIntent(.updateQuery("c"))

        await Task.yield()

        #expect(repository.searchedKeywords.isEmpty)
        #expect(viewModel.state.search.query == "c")
        #expect(viewModel.state.search.phase == .idle)
        #expect(viewModel.state.search.results.isEmpty)
    }

    @MainActor
    @Test func twoCharacterSearchQueryCallsRepositoryAfterDebounce() async throws {
        let repository = DebouncedSearchRecipeRepository()
        let viewModel = FeatureViewModel(repository: repository, searchDebounceDelay: 0)

        viewModel.onIntent(.updateQuery("ch"))

        try await waitUntil {
            repository.searchedKeywords == ["ch"]
        }

        #expect(repository.searchedKeywords == ["ch"])
        #expect(viewModel.state.search.results.map(\.name) == ["ch result"])
    }

    @MainActor
    @Test func newSearchInputCancelsPendingDebouncedQuery() async throws {
        let repository = DebouncedSearchRecipeRepository()
        let viewModel = FeatureViewModel(repository: repository, searchDebounceDelay: 50_000_000)

        viewModel.onIntent(.updateQuery("ch"))
        viewModel.onIntent(.updateQuery("chi"))

        try await waitUntil {
            repository.searchedKeywords == ["chi"]
        }

        #expect(repository.searchedKeywords == ["chi"])
        #expect(viewModel.state.search.results.map(\.name) == ["chi result"])
    }

    @MainActor
    @Test func randomPickItemsUpdateThroughIntent() {
        let viewModel = FeatureViewModel(repository: SearchRaceRecipeRepository())
        let items = [UIRecipeItem.new(id: "1", name: "One")]

        viewModel.onIntent(.updateRandomPickItems(items))

        #expect(viewModel.state.randomPick.items == items)
        #expect(viewModel.state.randomPick.phase == .content)
    }

    @MainActor
    @Test func loadIngredientsPopulatesState() async throws {
        let viewModel = FeatureViewModel(repository: DummyRecipeRepository())

        viewModel.onIntent(.loadIngredients)
        try await waitUntil {
            viewModel.state.ingredients.phase == .content
        }

        #expect(viewModel.state.ingredients.items.map(\.name) == ["Beef", "Garlic"])
        #expect(viewModel.state.ingredients.phase == .content)
    }

    @MainActor
    @Test func loadIngredientsWithEmptyResultSetsEmptyPhase() async throws {
        let viewModel = FeatureViewModel(repository: SearchRaceRecipeRepository())

        viewModel.onIntent(.loadIngredients)
        try await waitUntil {
            viewModel.state.ingredients.phase == .empty
        }

        #expect(viewModel.state.ingredients.items.isEmpty)
        #expect(viewModel.state.ingredients.phase == .empty)
    }

    @MainActor
    @Test func loadIngredientMealsPopulatesState() async throws {
        let viewModel = FeatureViewModel(repository: DummyRecipeRepository())

        viewModel.onIntent(.loadIngredientMeals("Beef"))
        try await waitUntil {
            viewModel.state.ingredientMeals.phase == .content
        }

        #expect(viewModel.state.ingredientMeals.ingredient == "Beef")
        #expect(viewModel.state.ingredientMeals.phase == .content)
        #expect(!viewModel.state.ingredientMeals.items.isEmpty)
    }

    @MainActor
    @Test func loadIngredientMealsWithEmptyResultSetsEmptyPhase() async throws {
        let viewModel = FeatureViewModel(repository: SearchRaceRecipeRepository())

        viewModel.onIntent(.loadIngredientMeals("Beef"))
        try await waitUntil {
            viewModel.state.ingredientMeals.phase == .empty
        }

        #expect(viewModel.state.ingredientMeals.ingredient == "Beef")
        #expect(viewModel.state.ingredientMeals.items.isEmpty)
        #expect(viewModel.state.ingredientMeals.phase == .empty)
    }
}

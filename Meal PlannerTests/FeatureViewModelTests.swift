//
//  FeatureViewModelTests.swift
//  Meal PlannerTests
//
//  Created by Codex on 15/7/2026.
//

import Testing
@testable import Meal_Planner

struct FeatureViewModelTests {

    @MainActor
    @Test func staleSearchCompletionDoesNotOverwriteCurrentQuery() async throws {
        let repository = SearchRaceRecipeRepository()
        let viewModel = FeatureViewModel(repository: repository)

        viewModel.onIntent(.updateQuery("slow"))
        viewModel.onIntent(.performSearch)

        try await Task.sleep(nanoseconds: 550_000_000)

        viewModel.onIntent(.updateQuery("fast"))
        viewModel.onIntent(.performSearch)

        try await Task.sleep(nanoseconds: 700_000_000)

        #expect(viewModel.state.search.query == "fast")
        #expect(viewModel.state.search.results.map(\.name) == ["fast result"])
    }

    @MainActor
    @Test func emptySearchQueryResetsSearchState() async throws {
        let viewModel = FeatureViewModel(repository: SearchRaceRecipeRepository())

        viewModel.onIntent(.updateQuery("chicken"))
        viewModel.onIntent(.performSearch)
        try await Task.sleep(nanoseconds: 600_000_000)

        viewModel.onIntent(.updateQuery(""))
        viewModel.onIntent(.performSearch)

        #expect(viewModel.state.search.query == "")
        #expect(viewModel.state.search.phase == .idle)
        #expect(viewModel.state.search.results.isEmpty)
    }

    @MainActor
    @Test func oneCharacterSearchQueryDoesNotCallRepository() async throws {
        let repository = DebouncedSearchRecipeRepository()
        let viewModel = FeatureViewModel(repository: repository)

        viewModel.onIntent(.updateQuery("c"))

        try await Task.sleep(nanoseconds: 600_000_000)

        #expect(repository.searchedKeywords.isEmpty)
        #expect(viewModel.state.search.query == "c")
        #expect(viewModel.state.search.phase == .idle)
        #expect(viewModel.state.search.results.isEmpty)
    }

    @MainActor
    @Test func twoCharacterSearchQueryWaitsForDebounceBeforeCallingRepository() async throws {
        let repository = DebouncedSearchRecipeRepository()
        let viewModel = FeatureViewModel(repository: repository)

        viewModel.onIntent(.updateQuery("ch"))
        try await Task.sleep(nanoseconds: 300_000_000)

        #expect(repository.searchedKeywords.isEmpty)

        try await Task.sleep(nanoseconds: 300_000_000)

        #expect(repository.searchedKeywords == ["ch"])
        #expect(viewModel.state.search.results.map(\.name) == ["ch result"])
    }

    @MainActor
    @Test func newSearchInputCancelsPendingDebouncedQuery() async throws {
        let repository = DebouncedSearchRecipeRepository()
        let viewModel = FeatureViewModel(repository: repository)

        viewModel.onIntent(.updateQuery("ch"))
        try await Task.sleep(nanoseconds: 250_000_000)
        viewModel.onIntent(.updateQuery("chi"))

        try await Task.sleep(nanoseconds: 650_000_000)

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
}

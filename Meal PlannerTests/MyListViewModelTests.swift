//
//  MyListViewModelTests.swift
//  Meal PlannerTests
//
//  Created by Codex on 15/7/2026.
//

import Testing
@testable import Meal_Planner

struct MyListViewModelTests {

    @MainActor
    @Test func myListLoadUsesLoadingThenEmptyState() async throws {
        let repository = FavoriteRecipeRepository()
        let viewModel = MyListViewModel(repository: repository)

        viewModel.onIntent(.loadList(.favourite))
        #expect(viewModel.state.phase == .loading)

        try await waitUntil {
            viewModel.state.phase == .empty
        }

        #expect(viewModel.state.phase == .empty)
        #expect(viewModel.state.items.isEmpty)
        #expect(viewModel.state.errorMessage == nil)
    }

    @MainActor
    @Test func myListLoadUsesContentStateWhenItemsExist() async throws {
        let favorite = makeRecipe(id: 1, title: "Fav", isFavorite: true)
        let repository = FavoriteRecipeRepository(favorites: [favorite])
        let viewModel = MyListViewModel(repository: repository)

        viewModel.onIntent(.loadList(.favourite))
        #expect(viewModel.state.phase == .loading)

        try await waitUntil {
            viewModel.state.phase == .content
        }

        #expect(viewModel.state.phase == .content)
        #expect(viewModel.state.items.map(\.id) == ["1"])
        #expect(viewModel.state.errorMessage == nil)
    }

    @MainActor
    @Test func myListLoadFailureUsesErrorPhaseWithoutToggleAlert() async throws {
        let repository = FavoriteRecipeRepository()
        repository.shouldFailLoad = true
        let viewModel = MyListViewModel(repository: repository)

        viewModel.onIntent(.loadList(.favourite))
        #expect(viewModel.state.phase == .loading)

        try await waitUntil {
            viewModel.state.phase == .error("Failed to load your list.")
        }

        #expect(viewModel.state.phase == .error("Failed to load your list."))
        #expect(viewModel.state.items.isEmpty)
        #expect(viewModel.state.errorMessage == nil)
    }

    @MainActor
    @Test func myListLoadsFiltersAndTogglesWithRollback() async throws {
        let favorite = makeRecipe(id: 1, title: "Fav", area: "Thai", category: "Seafood", isFavorite: true)
        let repository = FavoriteRecipeRepository(favorites: [favorite])
        let viewModel = MyListViewModel(repository: repository)

        viewModel.onIntent(.loadList(.favourite))
        try await waitUntil {
            viewModel.state.items.map(\.id) == ["1"]
        }

        #expect(viewModel.state.items.map(\.id) == ["1"])
        #expect(viewModel.state.availableAreas == ["Thai"])
        #expect(viewModel.state.availableCategories == ["Seafood"])

        viewModel.onIntent(.selectArea("Thai"))
        viewModel.onIntent(.selectCategory("Seafood"))
        #expect(viewModel.state.filteredItems.count == 1)

        viewModel.onIntent(.toggleFavorite(favorite.toUI()))
        try await waitUntil {
            viewModel.state.items.isEmpty
        }
        #expect(viewModel.state.items.isEmpty)

        repository.shouldFailUpdate = true
        let nonFavorite = makeRecipe(id: 2, title: "New", isFavorite: false).toUI()
        viewModel.onIntent(.toggleFavorite(nonFavorite))
        try await waitUntil {
            viewModel.state.errorMessage == "Failed to update your list. Please try again."
        }

        #expect(viewModel.state.items.contains(where: { $0.id == "2" }) == false)
        #expect(viewModel.state.errorMessage == "Failed to update your list. Please try again.")
    }

    @MainActor
    @Test func myListViewHistoryOmitsFilters() async throws {
        let repository = FavoriteRecipeRepository()
        let viewed = makeRecipe(id: 5, title: "Viewed", isFavorite: false)
        repository.viewed = [viewed]
        let viewModel = MyListViewModel(repository: repository)

        viewModel.onIntent(.loadList(.viewed))
        try await waitUntil {
            viewModel.state.items.map(\.id) == ["5"]
        }

        #expect(viewModel.state.showsFilters == false)
        viewModel.onIntent(.selectArea("Anything"))
        #expect(viewModel.state.filteredItems.map(\.id) == ["5"])
    }
}

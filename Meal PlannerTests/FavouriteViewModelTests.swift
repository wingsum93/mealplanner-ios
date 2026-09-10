//
//  FavouriteViewModelTests.swift
//  Meal PlannerTests
//
//  Created by Codex on 15/7/2026.
//

import Testing
@testable import Meal_Planner

struct FavouriteViewModelTests {

    @MainActor
    @Test func favouriteLoadUsesLoadingThenEmptyState() async throws {
        let repository = FavoriteRecipeRepository()
        let viewModel = FavouriteViewModel(repository: repository)

        viewModel.onIntent(.loadFavorites)
        #expect(viewModel.state.phase == .loading)

        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.state.phase == .empty)
        #expect(viewModel.state.items.isEmpty)
        #expect(viewModel.state.errorMessage == nil)
    }

    @MainActor
    @Test func favouriteLoadUsesContentStateWhenItemsExist() async throws {
        let favorite = makeRecipe(id: 1, title: "Fav", isFavorite: true)
        let repository = FavoriteRecipeRepository(favorites: [favorite])
        let viewModel = FavouriteViewModel(repository: repository)

        viewModel.onIntent(.loadFavorites)
        #expect(viewModel.state.phase == .loading)

        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.state.phase == .content)
        #expect(viewModel.state.items.map(\.id) == ["1"])
        #expect(viewModel.state.errorMessage == nil)
    }

    @MainActor
    @Test func favouriteLoadFailureUsesErrorPhaseWithoutToggleAlert() async throws {
        let repository = FavoriteRecipeRepository()
        repository.shouldFailLoad = true
        let viewModel = FavouriteViewModel(repository: repository)

        viewModel.onIntent(.loadFavorites)
        #expect(viewModel.state.phase == .loading)

        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.state.phase == .error("Failed to load favourites."))
        #expect(viewModel.state.items.isEmpty)
        #expect(viewModel.state.errorMessage == nil)
    }

    @MainActor
    @Test func favouriteLoadsFiltersAndTogglesWithRollback() async throws {
        let favorite = makeRecipe(id: 1, title: "Fav", area: "Thai", category: "Seafood", isFavorite: true)
        let repository = FavoriteRecipeRepository(favorites: [favorite])
        let viewModel = FavouriteViewModel(repository: repository)

        viewModel.onIntent(.loadFavorites)
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.state.items.map(\.id) == ["1"])
        #expect(viewModel.state.availableAreas == ["Thai"])
        #expect(viewModel.state.availableCategories == ["Seafood"])

        viewModel.onIntent(.selectArea("Thai"))
        viewModel.onIntent(.selectCategory("Seafood"))
        #expect(viewModel.state.filteredItems.count == 1)

        viewModel.onIntent(.toggleFavorite(favorite.toUI()))
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(viewModel.state.items.isEmpty)

        repository.shouldFailUpdate = true
        let nonFavorite = makeRecipe(id: 2, title: "New", isFavorite: false).toUI()
        viewModel.onIntent(.toggleFavorite(nonFavorite))
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.state.items.contains(where: { $0.id == "2" }) == false)
        #expect(viewModel.state.errorMessage == "Failed to update favourite. Please try again.")
    }
}

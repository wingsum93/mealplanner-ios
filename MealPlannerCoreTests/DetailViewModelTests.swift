//
//  DetailViewModelTests.swift
//  Meal PlannerTests
//
//  Created by Codex on 15/7/2026.
//

import Testing

struct DetailViewModelTests {

    @MainActor
    @Test func detailInitialFavoriteStateUsesSavedBookmark() {
        let savedFavorite = makeRecipe(id: 7, title: "Detail", isFavorite: true)
        let repository = FavoriteRecipeRepository(favorites: [savedFavorite])
        let viewModel = DetailViewModel(repository: repository)
        let staleItem = makeRecipe(id: 7, title: "Detail", isFavorite: false).toUI()

        viewModel.onIntent(.setItem(staleItem))

        #expect(viewModel.state.item?.isFavorite == true)
    }

    @MainActor
    @Test func detailToggleFavoriteRollsBackOnFailure() async throws {
        let repository = FavoriteRecipeRepository()
        repository.shouldFailUpdate = true
        let viewModel = DetailViewModel(repository: repository)
        let item = makeRecipe(id: 7, title: "Detail", isFavorite: false).toUI()

        viewModel.onIntent(.setItem(item))
        viewModel.onIntent(.toggleFavorite)

        #expect(viewModel.state.item?.isFavorite == true)
        try await waitUntil {
            viewModel.state.errorMessage == "Failed to update favourite. Please try again."
        }

        #expect(viewModel.state.item?.isFavorite == false)
        #expect(viewModel.state.isSavingFavorite == false)
        #expect(viewModel.state.errorMessage == "Failed to update favourite. Please try again.")
    }
}

//
//  SettingsViewModelTests.swift
//  Meal PlannerTests
//
//  Created by Codex on 15/7/2026.
//

import Testing
@testable import Meal_Planner

struct SettingsViewModelTests {

    @MainActor
    @Test func settingsLoadsInitialSummary() {
        let localDataSource = SettingsLocalDataSourceSpy()
        let viewModel = SettingsViewModel(localDataSource: localDataSource)

        #expect(localDataSource.summaryCallCount == 1)
        #expect(viewModel.state.summary == localDataSource.summary)
        #expect(viewModel.state.errorMessage == nil)
    }

    @MainActor
    @Test func settingsReloadsSummaryAfterClearingBrowseCache() {
        let localDataSource = SettingsLocalDataSourceSpy()
        localDataSource.summary = SettingsDataSummary(
            savedRecipeCount: 10,
            favoriteRecipeCount: 3,
            cachedCategoryCount: 2,
            cachedAreaCount: 4,
            cachedIngredientCount: 5
        )
        let viewModel = SettingsViewModel(localDataSource: localDataSource)

        viewModel.onIntent(.perform(.clearBrowseCache))

        #expect(localDataSource.clearBrowseCacheCallCount == 1)
        #expect(localDataSource.summaryCallCount == 2)
        #expect(viewModel.state.summary.savedRecipeCount == 3)
        #expect(viewModel.state.summary.favoriteRecipeCount == 3)
        #expect(viewModel.state.statusMessage == "Browse cache cleared. Favorite recipes were kept.")
        #expect(viewModel.state.errorMessage == nil)
    }

    @MainActor
    @Test func settingsReloadsSummaryAfterClearingLookupCaches() {
        let localDataSource = SettingsLocalDataSourceSpy()
        let viewModel = SettingsViewModel(localDataSource: localDataSource)

        viewModel.onIntent(.perform(.clearLookupCaches))

        #expect(localDataSource.clearLookupCachesCallCount == 1)
        #expect(localDataSource.summaryCallCount == 2)
        #expect(viewModel.state.summary.cachedCategoryCount == 0)
        #expect(viewModel.state.summary.cachedAreaCount == 0)
        #expect(viewModel.state.summary.cachedIngredientCount == 0)
        #expect(viewModel.state.statusMessage == "Lookup caches cleared.")
        #expect(viewModel.state.errorMessage == nil)
    }

    @MainActor
    @Test func settingsCallsFavoritesResetCallbackOnlyOnSuccess() {
        let localDataSource = SettingsLocalDataSourceSpy()
        var resetCallbackCount = 0
        let viewModel = SettingsViewModel(localDataSource: localDataSource) {
            resetCallbackCount += 1
        }

        viewModel.onIntent(.perform(.resetFavorites))

        #expect(localDataSource.resetFavoritesCallCount == 1)
        #expect(resetCallbackCount == 1)
        #expect(viewModel.state.summary.favoriteRecipeCount == 0)
        #expect(viewModel.state.statusMessage == "Favorites reset.")
        #expect(viewModel.state.errorMessage == nil)
    }

    @MainActor
    @Test func settingsReportsActionErrorsAndDoesNotCallResetCallback() {
        let localDataSource = SettingsLocalDataSourceSpy()
        let viewModel = SettingsViewModel(localDataSource: localDataSource)
        var resetCallbackCount = 0
        let failingViewModel = SettingsViewModel(localDataSource: localDataSource) {
            resetCallbackCount += 1
        }
        localDataSource.error = TestError.expected

        failingViewModel.onIntent(.perform(.resetFavorites))

        #expect(viewModel.state.errorMessage == nil)
        #expect(failingViewModel.state.errorMessage == TestError.expected.localizedDescription)
        #expect(failingViewModel.state.statusMessage == nil)
        #expect(resetCallbackCount == 0)

        failingViewModel.onIntent(.clearStatus)
        #expect(failingViewModel.state.errorMessage == nil)
    }

    @MainActor
    @Test func settingsCanReloadSummaryOnDemand() {
        let localDataSource = SettingsLocalDataSourceSpy()
        let viewModel = SettingsViewModel(localDataSource: localDataSource)
        localDataSource.summary = SettingsDataSummary(
            savedRecipeCount: 7,
            favoriteRecipeCount: 2,
            cachedCategoryCount: 9,
            cachedAreaCount: 6,
            cachedIngredientCount: 11
        )

        viewModel.onIntent(.loadSummary)

        #expect(localDataSource.summaryCallCount == 2)
        #expect(viewModel.state.summary.savedRecipeCount == 7)
        #expect(viewModel.state.summary.favoriteRecipeCount == 2)
    }

    @MainActor
    @Test func settingsReportsSummaryLoadErrors() {
        let localDataSource = SettingsLocalDataSourceSpy()
        localDataSource.error = TestError.expected
        let viewModel = SettingsViewModel(localDataSource: localDataSource)

        #expect(viewModel.state.errorMessage == TestError.expected.localizedDescription)

        viewModel.onIntent(.clearStatus)
        #expect(viewModel.state.errorMessage == nil)
    }
}

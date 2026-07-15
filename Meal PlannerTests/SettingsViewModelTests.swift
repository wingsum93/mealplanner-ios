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
    @Test func settingsReportsAndClearsActionErrors() {
        let localDataSource = SettingsLocalDataSourceSpy()
        localDataSource.error = TestError.expected
        let viewModel = SettingsViewModel(localDataSource: localDataSource)

        viewModel.onIntent(.perform(.clearCachedRecipes))
        #expect(viewModel.state.errorMessage == TestError.expected.localizedDescription)

        viewModel.onIntent(.clearError)
        #expect(viewModel.state.errorMessage == nil)
    }
}

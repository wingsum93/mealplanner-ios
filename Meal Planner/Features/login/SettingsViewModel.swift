//
//  SettingsViewModel.swift
//  Meal Planner
//
//  Created by eric ho on 5/8/2025.
//

import Foundation

private enum SettingsEvent: Equatable {
    case setError(String?)
}

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var state = SettingsState()
    private let localDataSource: RecipeLocalDataSource

    init(localDataSource: RecipeLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func onIntent(_ intent: SettingsIntent) {
        switch intent {
        case .perform(let action):
            perform(action)
        case .clearError:
            reduce(.setError(nil))
        }
    }

    private func perform(_ action: SettingsAction) {
        do {
            switch action {
            case .clearCachedRecipes:
                try localDataSource.clearCachedRecipes()
            case .resetFavorites:
                try localDataSource.resetFavorites()
            }
            reduce(.setError(nil))
        } catch {
            reduce(.setError(error.localizedDescription))
        }
    }

    private func reduce(_ event: SettingsEvent) {
        switch event {
        case .setError(let message):
            state.errorMessage = message
        }
    }
}

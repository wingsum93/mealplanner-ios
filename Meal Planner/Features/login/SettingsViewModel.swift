//
//  SettingsViewModel.swift
//  Meal Planner
//
//  Created by eric ho on 5/8/2025.
//

import Foundation

struct SettingsState: Equatable {
    var errorMessage: String?
}

enum SettingsAction: String, Identifiable, Equatable {
    case clearCachedRecipes
    case resetFavorites

    var id: String { rawValue }

    var confirmButtonTitle: String {
        switch self {
        case .clearCachedRecipes:
            return "Clear cache"
        case .resetFavorites:
            return "Reset favorites"
        }
    }

    var confirmMessage: String {
        switch self {
        case .clearCachedRecipes:
            return "This removes all cached recipes from this device."
        case .resetFavorites:
            return "This clears the favorite flag for all recipes."
        }
    }
}

enum SettingsIntent {
    case perform(SettingsAction)
    case clearError
}

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

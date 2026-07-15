//
//  SettingsState.swift
//  Meal Planner
//
//  Created by eric ho on 5/8/2025.
//

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

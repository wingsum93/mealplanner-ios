//
//  SettingsState.swift
//  Meal Planner
//
//  Created by eric ho on 5/8/2025.
//

struct SettingsDataSummary: Equatable {
    var savedRecipeCount: Int = 0
    var favoriteRecipeCount: Int = 0
    var cachedCategoryCount: Int = 0
    var cachedAreaCount: Int = 0
    var cachedIngredientCount: Int = 0
}

struct SettingsState: Equatable {
    var summary = SettingsDataSummary()
    var statusMessage: String?
    var errorMessage: String?
}

enum SettingsAction: String, Identifiable, Equatable {
    case clearBrowseCache
    case clearLookupCaches
    case resetFavorites

    var id: String { rawValue }

    var confirmButtonTitle: String {
        switch self {
        case .clearBrowseCache:
            return "Clear browse cache"
        case .clearLookupCaches:
            return "Clear lookup caches"
        case .resetFavorites:
            return "Reset favorites"
        }
    }

    var confirmMessage: String {
        switch self {
        case .clearBrowseCache:
            return "This removes saved browse results from this device, but keeps favorited recipes."
        case .clearLookupCaches:
            return "This clears cached category, area, and ingredient lists. They will reload from TheMealDB when needed."
        case .resetFavorites:
            return "This clears the favorite flag for all recipes."
        }
    }

    var successMessage: String {
        switch self {
        case .clearBrowseCache:
            return "Browse cache cleared. Favorite recipes were kept."
        case .clearLookupCaches:
            return "Lookup caches cleared."
        case .resetFavorites:
            return "Favorites reset."
        }
    }
}

enum SettingsIntent {
    case loadSummary
    case perform(SettingsAction)
    case clearStatus
}

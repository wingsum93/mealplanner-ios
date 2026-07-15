//
//  FavouriteIntent.swift
//  Meal Planner
//
//  Created by eric ho on 29/8/2025.
//

enum FavouriteIntent {
    case loadFavorites
    case selectArea(String?)
    case selectCategory(String?)
    case toggleFavorite(UIRecipeItem)
    case clearError
}

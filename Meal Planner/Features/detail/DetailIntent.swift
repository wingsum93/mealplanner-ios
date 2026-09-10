//
//  DetailIntent.swift
//  Meal Planner
//
//  Created by eric ho on 17/8/2025.
//

// MARK: - Intents (from UI)
enum DetailIntent {
    case toggleFavorite
    case clearError
    case dismiss
    case setItem(_ item: UIRecipeItem)
}

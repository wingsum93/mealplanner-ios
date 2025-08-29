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

// MARK: - Events (Reducer inputs)
enum DetailEvent: Equatable {
    case setItem(UIRecipeItem?)
    case setSavingFavorite(Bool)
    case setError(String?)
}

// MARK: - Reducer (pure)
@inline(__always)
func reduce(state: inout DetailState, event: DetailEvent) {
    switch event {
    case .setItem(let item):
        state.item = item
    case .setSavingFavorite(let saving):
        state.isSavingFavorite = saving
    case .setError(let msg):
        state.errorMessage = msg
    }
}

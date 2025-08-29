//
//  DetailViewModel.swift
//  Meal Planner
//
//  Created by eric ho on 16/8/2025.
//
import SwiftUI
import Observation

@MainActor
final class DetailViewModel: ObservableObject {
    @Published private(set) var state: DetailState
    private let repo: RecipeRepository

    init( repository: RecipeRepository) {
        self.repo = repository
        self.state = .init()
    }

    func onIntent(_ intent: DetailIntent) {
        switch intent {
        case .setItem(let item):
            setData(item)
        case .toggleFavorite:
            toggleFavorite()
        case .clearError:
            reduce(state: &state, event: .setError(nil))
        case .dismiss:
            state.item = nil
        }
    }

    private func setData(_ item:UIRecipeItem){
        state.item = item
        print(item)
        
    }
    private func toggleFavorite() {
        // 1) Optimistic update
        let old = state.item
        guard old != nil else { return }
        let new = old!.togglingFavorite()
        reduce(state: &state, event: .setItem(new))
        reduce(state: &state, event: .setSavingFavorite(true))

        // 2) Persist
        Task {
            do {
                try await repo.updateFavorite(id: Int64(new.id) ?? Int64(0), isFavorite: new.isFavorite)
                reduce(state: &state, event: .setSavingFavorite(false))
            } catch {
                // 3) Roll back on failure
                reduce(state: &state, event: .setItem(old))
                reduce(state: &state, event: .setSavingFavorite(false))
                reduce(state: &state, event: .setError("Failed to update favourite. Please try again."))
                #if DEBUG
                print("❌ toggleFavorite error:", error)
                #endif
            }
        }
    }
}

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
        guard let domainItem = item.toDomain() else {
            #if DEBUG
            print("❌ saveRecipe error: invalid id \(item.id)")
            #endif
            return
        }
        
        do {
            try repo.saveRecipe(domainItem)
        } catch {
            #if DEBUG
            print("❌ saveRecipe error:", error)
            #endif
        }
        
    }
    private func toggleFavorite() {
        // 1) Optimistic update
        let old = state.item
        guard let old else { return }
        guard let id = Int64(old.id) else {
            reduce(state: &state, event: .setError("Invalid recipe id. Please try again."))
            return
        }
        let new = old.togglingFavorite()
        reduce(state: &state, event: .setItem(new))
        reduce(state: &state, event: .setSavingFavorite(true))

        // 2) Persist
        Task {
            do {
                try await repo.updateFavorite(id: id, isFavorite: new.isFavorite)
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

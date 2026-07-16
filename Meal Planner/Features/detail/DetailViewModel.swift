//
//  DetailViewModel.swift
//  Meal Planner
//
//  Created by eric ho on 16/8/2025.
//
import SwiftUI
import Observation

private enum DetailEvent: Equatable {
    case setItem(UIRecipeItem?)
    case setSavingFavorite(Bool)
    case setError(String?)
}

@MainActor
final class DetailViewModel: ObservableObject {
    @Published private(set) var state: DetailState
    private let repo: RecipeRepository
    private var favoriteTask: Task<Void, Never>?

    init( repository: RecipeRepository) {
        self.repo = repository
        self.state = .init()
    }

    deinit { favoriteTask?.cancel() }

    func onIntent(_ intent: DetailIntent) {
        switch intent {
        case .setItem(let item):
            setData(item)
        case .toggleFavorite:
            toggleFavorite()
        case .clearError:
            reduce(.setError(nil))
        case .dismiss:
            reduce(.setItem(nil))
        }
    }

    private func setData(_ item:UIRecipeItem){
        guard let id = Int64(item.id) else {
            #if DEBUG
            print("❌ saveRecipe error: invalid id \(item.id)")
            #endif
            return
        }

        let reconciledItem = item.with(isFavorite: repo.isFavourite(id: id))
        reduce(.setItem(reconciledItem))

        guard let domainItem = reconciledItem.toDomain() else { return }

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
            reduce(.setError("Invalid recipe id. Please try again."))
            return
        }
        let new = old.togglingFavorite()
        reduce(.setItem(new))
        reduce(.setSavingFavorite(true))

        // 2) Persist
        favoriteTask?.cancel()
        favoriteTask = Task { [weak self] in
            guard let self else { return }
            do {
                try repo.updateFavorite(id: id, isFavorite: new.isFavorite)
                reduce(.setSavingFavorite(false))
            } catch {
                // 3) Roll back on failure
                reduce(.setItem(old))
                reduce(.setSavingFavorite(false))
                reduce(.setError("Failed to update favourite. Please try again."))
                #if DEBUG
                print("❌ toggleFavorite error:", error)
                #endif
            }
        }
    }

    private func reduce(_ event: DetailEvent) {
        switch event {
        case .setItem(let item):
            state.item = item
        case .setSavingFavorite(let saving):
            state.isSavingFavorite = saving
        case .setError(let msg):
            state.errorMessage = msg
        }
    }
}

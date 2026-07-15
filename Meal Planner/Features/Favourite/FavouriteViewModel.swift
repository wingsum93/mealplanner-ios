//
//  FavouriteViewModel.swift
//  Meal Planner
//
//  Created by eric ho on 29/8/2025.
//
import Foundation

private enum FavouriteEvent: Equatable {
    case setPhase(LoadPhase)
    case setItems([UIRecipeItem])
    case setSelectedArea(String?)
    case setSelectedCategory(String?)
    case setError(String?)
    case setFavorite(UIRecipeItem, isFavorite: Bool)
}

@MainActor
final class FavouriteViewModel: ObservableObject {
    @Published private(set) var state = FavouriteState()
    private let repo: RecipeRepository
    private var task: Task<Void, Never>? = nil

    init(repository: RecipeRepository) {
        self.repo = repository
    }

    deinit { task?.cancel() }

    func onIntent(_ intent: FavouriteIntent) {
        switch intent {
        case .loadFavorites:
            loadFavorites()
        case .selectArea(let area):
            reduce(.setSelectedArea(area))
        case .selectCategory(let category):
            reduce(.setSelectedCategory(category))
        case .toggleFavorite(let item):
            toggleFavorite(item)
        case .clearError:
            reduce(.setError(nil))
        }
    }

    private func loadFavorites() {
        task?.cancel()
        reduce(.setPhase(.loading))
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try repo.getAllFavoriteRecipes().map { $0.toUI() }
                if !Task.isCancelled {
                    reduce(.setItems(items))
                }
            } catch {
                if !Task.isCancelled {
                    reduce(.setItems([]))
                    reduce(.setPhase(.error("Failed to load favourites.")))
                    reduce(.setError(error.localizedDescription))
                }
            }
        }
    }

    private func toggleFavorite(_ item: UIRecipeItem) {
        guard let id = Int64(item.id) else {
            reduce(.setError("Invalid recipe id. Please try again."))
            return
        }

        let newFavoriteValue = !item.isFavorite
        reduce(.setFavorite(item, isFavorite: newFavoriteValue))

        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            do {
                if let domainItem = item.toDomain() {
                    try repo.saveRecipe(domainItem)
                }
                try repo.updateFavorite(id: id, isFavorite: newFavoriteValue)
                let items = try repo.getAllFavoriteRecipes().map { $0.toUI() }
                if !Task.isCancelled {
                    reduce(.setItems(items))
                }
            } catch {
                if !Task.isCancelled {
                    reduce(.setFavorite(item, isFavorite: item.isFavorite))
                    reduce(.setError("Failed to update favourite. Please try again."))
                }
            }
        }
    }

    private func reduce(_ event: FavouriteEvent) {
        switch event {
        case .setPhase(let phase):
            state.phase = phase
        case .setItems(let items):
            state.items = items
            state.phase = items.isEmpty ? .empty : .content
        case .setSelectedArea(let area):
            state.selectedArea = area
        case .setSelectedCategory(let category):
            state.selectedCategory = category
        case .setError(let message):
            state.errorMessage = message
        case .setFavorite(let item, let isFavorite):
            let updatedItem = item.with(isFavorite: isFavorite)
            if isFavorite {
                if let index = state.items.firstIndex(where: { $0.id == item.id }) {
                    state.items[index] = updatedItem
                } else {
                    state.items.append(updatedItem)
                }
            } else {
                state.items.removeAll { $0.id == item.id }
            }
            state.phase = state.items.isEmpty ? .empty : .content
        }
    }
}

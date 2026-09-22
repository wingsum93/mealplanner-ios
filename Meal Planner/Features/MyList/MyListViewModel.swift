//
//  MyListViewModel.swift
//  Meal Planner
//
//  Created by eric ho on 22/9/2026.
//
import Foundation

@MainActor
final class MyListViewModel: ObservableObject {
    @Published private(set) var state = MyListState()
    private let repo: RecipeRepository
    private var task: Task<Void, Never>? = nil

    init(repository: RecipeRepository) {
        self.repo = repository
    }

    deinit { task?.cancel() }

    func onIntent(_ intent: MyListIntent) {
        switch intent {
        case .loadList(let type):
            loadList(type)
        case .selectList(let type):
            guard state.selectedList != type else { return }
            state.selectedList = type
            state.selectedArea = nil
            state.selectedCategory = nil
            loadList(type)
        case .selectArea(let area):
            state.selectedArea = area
        case .selectCategory(let category):
            state.selectedCategory = category
        case .toggleFavorite(let item):
            toggle(item, type: .favourite)
        case .toggleMastered(let item):
            toggle(item, type: .mastered)
        case .clearError:
            state.errorMessage = nil
        }
    }

    private func loadList(_ type: RecipeListType) {
        task?.cancel()
        state.selectedList = type
        state.phase = .loading
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await repo.getRecipesInList(type: type)
                guard !Task.isCancelled else { return }
                state.items = items.map { $0.toUI() }
                state.phase = items.isEmpty ? .empty : .content
            } catch {
                guard !Task.isCancelled else { return }
                state.items = []
                state.phase = .error("Failed to load your list.")
            }
        }
    }

    private func toggle(_ item: UIRecipeItem, type: RecipeListType) {
        guard let domainItem = item.toDomain() else {
            state.errorMessage = "Invalid recipe id. Please try again."
            return
        }

        let newValue: Bool
        switch type {
        case .favourite:
            newValue = !item.isFavorite
        case .mastered:
            newValue = !repo.isRecipeInList(id: domainItem.id, type: .mastered)
        case .viewed:
            return
        }

        // Optimistic removal when the item leaves the list currently on screen.
        let previousItems = state.items
        let previousPhase = state.phase
        if state.selectedList == type && !newValue {
            state.items.removeAll { $0.id == item.id }
            state.phase = state.items.isEmpty ? .empty : .content
        }

        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            do {
                try repo.setRecipeInList(domainItem, type: type, isIncluded: newValue)
                let items = try await repo.getRecipesInList(type: state.selectedList)
                guard !Task.isCancelled else { return }
                state.items = items.map { $0.toUI() }
                state.phase = items.isEmpty ? .empty : .content
            } catch {
                guard !Task.isCancelled else { return }
                state.items = previousItems
                state.phase = previousPhase
                state.errorMessage = "Failed to update your list. Please try again."
            }
        }
    }
}

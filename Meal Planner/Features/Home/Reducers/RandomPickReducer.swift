//
//  RandomPickReducer.swift
//  Meal Planner
//

import Foundation

@MainActor
final class RandomPickReducer {
    private(set) var state = RandomPickState()

    var onChange: (() -> Void)?

    private let repo: RecipeRepository
    private var randomPickTask: Task<Void, Never>?
    private var favoriteTasks: [String: Task<Void, Never>] = [:]

    init(repository: RecipeRepository) {
        self.repo = repository
    }

    deinit {
        randomPickTask?.cancel()
        favoriteTasks.values.forEach { $0.cancel() }
    }

    func load() {
        randomPickTask?.cancel()
        reduce(.setRandomPickPhase(.loading))
        randomPickTask = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await repo.getRandom10Recipe().map { $0.toUI() }.dedupedByID()
                guard !Task.isCancelled else { return }
                reduce(.setRandomPickItems(items))
            } catch {
                guard !Task.isCancelled else { return }
                reduce(.setRandomPickPhase(.error("Couldn’t load random picks. Pull to retry.")))
            }
        }
    }

    func updateItems(_ items: [UIRecipeItem]) {
        reduce(.setRandomPickItems(items))
    }

    func saveFavorite(_ item: UIRecipeItem) {
        guard item.isFavorite == false else { return }
        guard let domainItem = item.with(isFavorite: true).toDomain() else {
            reduce(.setRandomPickActionError("Invalid recipe id. Please try again."))
            return
        }

        favoriteTasks[item.id]?.cancel()
        let task = Task { [weak self] in
            guard let self, Task.isCancelled == false else { return }
            do {
                try repo.setRecipeInList(domainItem, type: .favourite, isIncluded: true)
            } catch {
                guard Task.isCancelled == false else { return }
                reduce(.setRandomPickActionError("Failed to save favourite. Please try again."))
            }
            favoriteTasks[item.id] = nil
        }
        favoriteTasks[item.id] = task
    }

    func undoFavorite(_ item: UIRecipeItem) {
        guard item.isFavorite == false else { return }
        guard let domainItem = item.toDomain() else {
            reduce(.setRandomPickActionError("Invalid recipe id. Please try again."))
            return
        }

        favoriteTasks[item.id]?.cancel()
        let task = Task { [weak self] in
            guard let self, Task.isCancelled == false else { return }
            do {
                try repo.setRecipeInList(domainItem, type: .favourite, isIncluded: false)
            } catch {
                guard Task.isCancelled == false else { return }
                reduce(.setRandomPickActionError("Failed to undo favourite. Please try again."))
            }
            favoriteTasks[item.id] = nil
        }
        favoriteTasks[item.id] = task
    }

    func clearActionError() {
        reduce(.setRandomPickActionError(nil))
    }

    private enum Event {
        case setRandomPickPhase(LoadPhase)
        case setRandomPickItems([UIRecipeItem])
        case setRandomPickActionError(String?)
    }

    private func reduce(_ event: Event) {
        switch event {
        case .setRandomPickPhase(let phase):
            state.phase = phase
        case .setRandomPickItems(let items):
            state.items = items
            state.phase = items.isEmpty ? .empty : .content
        case .setRandomPickActionError(let message):
            state.actionErrorMessage = message
        }
        onChange?()
    }
}

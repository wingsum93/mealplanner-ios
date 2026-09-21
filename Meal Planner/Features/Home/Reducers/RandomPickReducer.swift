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

    init(repository: RecipeRepository) {
        self.repo = repository
    }

    deinit {
        randomPickTask?.cancel()
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

    private enum Event {
        case setRandomPickPhase(LoadPhase)
        case setRandomPickItems([UIRecipeItem])
    }

    private func reduce(_ event: Event) {
        switch event {
        case .setRandomPickPhase(let phase):
            state.phase = phase
        case .setRandomPickItems(let items):
            state.items = items
            state.phase = items.isEmpty ? .empty : .content
        }
        onChange?()
    }
}

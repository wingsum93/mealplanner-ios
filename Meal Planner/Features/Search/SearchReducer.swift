//
//  SearchReducer.swift
//  Meal Planner
//

import Foundation

@MainActor
final class SearchReducer {
    private(set) var state = SearchState()

    var onChange: (() -> Void)?

    nonisolated static let defaultSearchDebounceDelay: UInt64 = 500_000_000
    private static let minimumSearchQueryLength = 2

    private let repo: RecipeRepository
    private let searchDebounceDelay: UInt64
    private var searchTask: Task<Void, Never>?
    private var searchDebounceTask: Task<Void, Never>?

    init(
        repository: RecipeRepository,
        searchDebounceDelay: UInt64 = 500_000_000
    ) {
        self.repo = repository
        self.searchDebounceDelay = searchDebounceDelay
    }

    deinit {
        searchTask?.cancel()
        searchDebounceTask?.cancel()
    }

    func updateQuery(_ query: String) {
        reduce(.setSearchQuery(query))
        debounceSearch()
    }

    func performSearch() {
        debounceSearch()
    }

    func updateFavorite(id: String, isFavorite: Bool) {
        reduce(.setSearchFavorite(id: id, isFavorite: isFavorite))
    }

    private func debounceSearch() {
        searchDebounceTask?.cancel()
        let q = searchQuery(from: state.query)
        guard q.count >= Self.minimumSearchQueryLength else {
            searchTask?.cancel()
            reduce(.resetSearch)
            return
        }

        searchDebounceTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: self?.searchDebounceDelay ?? Self.defaultSearchDebounceDelay)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            self?.search(query: q)
        }
    }

    private func search(query: String) {
        searchTask?.cancel()
        let q = searchQuery(from: query)
        if q.count < Self.minimumSearchQueryLength {
            reduce(.resetSearch)
            return
        }
        reduce(.setSearchPhase(.loading))
        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await repo.searchByName(q).map { $0.toUI() }
                guard !Task.isCancelled, searchQuery(from: state.query) == q else { return }
                reduce(.setSearchResults(items))
            } catch {
                guard !Task.isCancelled, searchQuery(from: state.query) == q else { return }
                reduce(.setSearchPhase(.error("Search failed.")))
            }
        }
    }

    private func searchQuery(from query: String) -> String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private enum Event {
        case setSearchQuery(String)
        case setSearchPhase(LoadPhase)
        case setSearchResults([UIRecipeItem])
        case setSearchFavorite(id: String, isFavorite: Bool)
        case resetSearch
    }

    private func reduce(_ event: Event) {
        switch event {
        case .setSearchQuery(let query):
            state.query = query
        case .setSearchPhase(let phase):
            state.phase = phase
        case .setSearchResults(let results):
            state.results = results
            state.phase = results.isEmpty ? .empty : .content
        case .setSearchFavorite(let id, let isFavorite):
            guard let index = state.results.firstIndex(where: { $0.id == id }) else { return }
            state.results[index] = state.results[index].with(isFavorite: isFavorite)
        case .resetSearch:
            state.phase = .idle
            state.results = []
        }
        onChange?()
    }
}

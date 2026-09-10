//
//  HomeViewModel.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import Foundation
import Combine

private enum FeatureEvent: Equatable {
    case setHomePhase(LoadPhase)
    case setHomeContent(featured: UIRecipeItem?, areas: [String], categories: [String], randomTen: [UIRecipeItem])
    case setArea(AreaListState)
    case setAreaItems([UIRecipeItem])
    case setAreaPhase(LoadPhase)
    case setCategory(CategoryListState)
    case setCategoryItems([UIRecipeItem])
    case setCategoryPhase(LoadPhase)
    case setSearchQuery(String)
    case setSearchPhase(LoadPhase)
    case setSearchResults([UIRecipeItem])
    case setSearchFavorite(id: String, isFavorite: Bool)
    case resetSearch
    case setRandomPickPhase(LoadPhase)
    case setRandomPickItems([UIRecipeItem])
}

@MainActor
final class FeatureViewModel: ObservableObject {
    @Published private(set) var state = FeatureState()
    private static let searchDebounceDelay: UInt64 = 500_000_000
    private static let minimumSearchQueryLength = 2
    
    private let repo: RecipeRepository
    
    // cancel bags per sub-feature
    private var homeTask: Task<Void, Never>?
    private var areaTask: Task<Void, Never>?
    private var categoryTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private var detailTask: Task<Void, Never>?
    private var randomPickTask: Task<Void, Never>?
    // search debounce
    private var searchDebounceTask: Task<Void, Never>?
    
    init(repository: RecipeRepository) {
        self.repo = repository
    }
    
    func onIntent(_ intent: HomeIntent) {
        switch intent {
            // MARK: Home
        case .loadHome, .refreshHome:
            loadHome()

        case .loadRandomPick:
            loadRandomPick()
        case .updateRandomPickItems(let items):
            reduce(.setRandomPickItems(items))
            
            // MARK: Lists
        case .loadArea(let area):         loadArea(area)
        case .loadCategory(let category): loadCategory(category)
            
            // MARK: Search
        case .updateQuery(let q):
            reduce(.setSearchQuery(q))
            debounceSearch()
            
        case .performSearch:
            debounceSearch()

        case .updateSearchFavorite(let id, let isFavorite):
            reduce(.setSearchFavorite(id: id, isFavorite: isFavorite))
            
        }
    
    }
    
    
    // HOME
    private func loadHome() {
        homeTask?.cancel()
        reduce(.setHomePhase(.loading))
        homeTask = Task { [weak self] in
            guard let self else { return }
            async let featured = repo.getRandomRecipe()
            async let areas    = repo.getAllArea()
            async let cats     = repo.getAllCategory()
            async let random10 = withThrowingTaskGroup(of: UIRecipeItem?.self) { group -> [UIRecipeItem] in
                // 10 randoms in parallel, filter nils and dedupe by id
                for _ in 0..<10 {
                    group.addTask { try? await self.repo.getRandomRecipe().toUI() }
                }
                var out: [UIRecipeItem] = []
                for try await item in group {
                    if let x = item, !out.contains(where: { $0.id == x.id }) { out.append(x) }
                }
                return out
            }
            do {
                let (f, a, c, r10) = try await (featured, areas, cats, random10)
                let featured = f.toUI()
                reduce(.setHomeContent(featured: featured, areas: a, categories: c, randomTen: r10))
            } catch {
                reduce(.setHomePhase(.error("Couldn’t load home. Pull to retry.")))
            }
        }
    }

    // RANDOM PICK
    private func loadRandomPick() {
        randomPickTask?.cancel()
        reduce(.setRandomPickPhase(.loading))
        randomPickTask = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await withThrowingTaskGroup(of: UIRecipeItem?.self) { group -> [UIRecipeItem] in
                    for _ in 0..<10 {
                        group.addTask { try? await self.repo.getRandomRecipe().toUI() }
                    }
                    var out: [UIRecipeItem] = []
                    for try await item in group {
                        if let x = item, !out.contains(where: { $0.id == x.id }) { out.append(x) }
                    }
                    return out
                }
                if Task.isCancelled { return }
                reduce(.setRandomPickItems(items))
            } catch {
                if Task.isCancelled { return }
                reduce(.setRandomPickPhase(.error("Couldn’t load random picks. Pull to retry.")))
            }
        }
    }
    
    // AREA LIST
    private func loadArea(_ area: String) {
        areaTask?.cancel()
        reduce(.setArea(AreaListState(phase: .loading, area: area, items: [])))
        areaTask = Task {[weak self] in
            guard let self else { return }
            do {
                // 1) Base list
                let base = try await repo.getByArea(area).map { $0.toUI() }
                if Task.isCancelled { return }
                
                // 2) Concurrently fetch details and prefer them if available
                let enriched = try await withThrowingTaskGroup(of: (String, UIRecipeItem?).self) { group in
                    for item in base {
                        group.addTask {
                            // getRecipeDetail might return nil; prefer base item if so
                            let detail = try await self.repo.getRecipeDetail(id: item.id).toUI()
                            return (item.id, detail)
                        }
                    }
                    var dict: [String: UIRecipeItem] = [:]
                    for try await (id, detail) in group {
                        if let d = detail { dict[id] = d }
                    }
                    // Preserve original order; fallback to base when no detail
                    return base.map { dict[$0.id] ?? $0 }
                }
                
                if Task.isCancelled { return }
                self.reduce(.setAreaItems(enriched))
            } catch {
                if Task.isCancelled { return }
                self.reduce(.setAreaPhase(.error("Failed to load \(area).")))
            }
        }
    }
    
    // CATEGORY LIST
    private func loadCategory(_ category: String) {
        categoryTask?.cancel()
        reduce(.setCategory(CategoryListState(phase: .loading, category: category, items: [])))
        categoryTask = Task {[weak self] in
            guard let self else { return }
            do {
                // 1) Base list
                let base = try await repo.getByCategory(category).map { $0.toUI() }
                if Task.isCancelled { return }
                
                // 2) Concurrently fetch details and prefer them if available
                let enriched = try await withThrowingTaskGroup(of: (String, UIRecipeItem?).self) { group in
                    for item in base {
                        group.addTask {
                            // getRecipeDetail might return nil; prefer base item if so
                            let detail = try await self.repo.getRecipeDetail(id: item.id).toUI()
                            return (item.id, detail)
                        }
                    }
                    var dict: [String: UIRecipeItem] = [:]
                    for try await (id, detail) in group {
                        if let d = detail { dict[id] = d }
                    }
                    // Preserve original order; fallback to base when no detail
                    return base.map { dict[$0.id] ?? $0 }
                }
                
                if Task.isCancelled { return }
                self.reduce(.setCategoryItems(enriched))
            } catch {
                if Task.isCancelled { return }
                self.reduce(.setCategoryPhase(.error("Failed to load \(category).")))
            }
        }
    }
    
    // SEARCH
    private func debounceSearch() {
        searchDebounceTask?.cancel()
        let q = searchQuery(from: state.search.query)
        guard q.count >= Self.minimumSearchQueryLength else {
            searchTask?.cancel()
            reduce(.resetSearch)
            return
        }

        searchDebounceTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: Self.searchDebounceDelay)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            await self?.search(query: q)
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
                guard !Task.isCancelled, searchQuery(from: state.search.query) == q else { return }
                reduce(.setSearchResults(items))
            } catch {
                guard !Task.isCancelled, searchQuery(from: state.search.query) == q else { return }
                reduce(.setSearchPhase(.error("Search failed.")))
            }
        }
    }

    private func searchQuery(from query: String) -> String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func reduce(_ event: FeatureEvent) {
        switch event {
        case .setHomePhase(let phase):
            state.home.phase = phase
        case .setHomeContent(let featured, let areas, let categories, let randomTen):
            state.home.featured = featured
            state.home.areas = areas
            state.home.categories = categories
            state.home.randomTen = randomTen
            let hasContent = featured != nil || !areas.isEmpty || !categories.isEmpty || !randomTen.isEmpty
            state.home.phase = hasContent ? .content : .empty
        case .setArea(let area):
            state.area = area
        case .setAreaItems(let items):
            state.area.items = items
            state.area.phase = items.isEmpty ? .empty : .content
        case .setAreaPhase(let phase):
            state.area.phase = phase
        case .setCategory(let category):
            state.category = category
        case .setCategoryItems(let items):
            state.category.items = items
            state.category.phase = items.isEmpty ? .empty : .content
        case .setCategoryPhase(let phase):
            state.category.phase = phase
        case .setSearchQuery(let query):
            state.search.query = query
        case .setSearchPhase(let phase):
            state.search.phase = phase
        case .setSearchResults(let results):
            state.search.results = results
            state.search.phase = results.isEmpty ? .empty : .content
        case .setSearchFavorite(let id, let isFavorite):
            guard let index = state.search.results.firstIndex(where: { $0.id == id }) else { return }
            state.search.results[index] = state.search.results[index].with(isFavorite: isFavorite)
        case .resetSearch:
            state.search.phase = .idle
            state.search.results = []
        case .setRandomPickPhase(let phase):
            state.randomPick.phase = phase
        case .setRandomPickItems(let items):
            state.randomPick.items = items
            state.randomPick.phase = items.isEmpty ? .empty : .content
        }
    }
}

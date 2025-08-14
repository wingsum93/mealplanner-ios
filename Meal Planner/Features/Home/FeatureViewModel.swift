//
//  HomeViewModel.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import Foundation
import Combine

@MainActor
final class FeatureViewModel: ObservableObject {
    @Published var state = FeatureState()
    
    private let repo: RecipeRepository
    
    // cancel bags per sub-feature
    private var homeTask: Task<Void, Never>?
    private var areaTask: Task<Void, Never>?
    private var categoryTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private var detailTask: Task<Void, Never>?
    // search debounce
    private var searchDebounceTask: Task<Void, Never>?
    
    init(repository: RecipeRepository) {
        self.repo = repository
    }
    
    func onIntent(_ intent: HomeIntent) {
        switch intent {
            
            // MARK: Navigation
        case .goToArea(let a):
            state.path.append(.area(a))
            onIntent(.loadArea(a))
            
        case .goToCategory(let c):
            state.path.append(.category(c))
            onIntent(.loadCategory(c))
            
        case .goToSearch:
            state.path.append(.search)
            
        case .goToDetail(let id):
            state.path.append(.detail(id))
            onIntent(.loadDetail(id))
            
        case .pop:
            if !state.path.isEmpty { _ = state.path.removeLast() }
            
            // MARK: Home
        case .loadHome, .refreshHome:
            loadHome()
            
            // MARK: Lists
        case .loadArea(let area):         loadArea(area)
        case .loadCategory(let category): loadCategory(category)
            
            // MARK: Search
        case .updateQuery(let q):
            state.search.query = q
            debounceSearch()
            
        case .performSearch:
            search(query: state.search.query)
            
            // MARK: Detail
        case .loadDetail(let id):
            loadDetail(id)
        case .toggleFavorite(let id, let isFavorite):
            //tbc
            toggleFavorite(id: id, to: isFavorite)
        }
    
    }
    
    
    // HOME
    private func loadHome() {
        print("load hoem")
        homeTask?.cancel()
        state.home.phase = .loading
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
                // Debug log：原始數據
                print("🔍 Featured raw:", f)
                print("🔍 Areas count:", a.count, "->", a)
                print("🔍 Categories count:", c.count, "->", c)
                print("🔍 Random 10 count:", r10.count)
                // 轉 UI model 後
                let fUI = f.toUI()
                print("✅ Featured UI model:", fUI)
                
                state.home.featured = f.toUI()
                state.home.areas = a
                state.home.categories = c
                state.home.randomTen = r10
                print("eric here")
                print(f.toUI())
                let has = state.home.featured != nil || !a.isEmpty || !c.isEmpty || !r10.isEmpty
                state.home.phase = has ? .content : .empty
            } catch {
                print("❌ Home load error:", error.localizedDescription)
                state.home.phase = .error("Couldn’t load home. Pull to retry.")
            }
        }
    }
    
    // AREA LIST
    private func loadArea(_ area: String) {
        areaTask?.cancel()
        state.area = AreaListState(phase: .loading, area: area, items: [])
        areaTask = Task {
            do {
                let items = try await repo.getByArea(area).map { $0.toUI() }
                state.area.items = items
                state.area.phase = items.isEmpty ? .empty : .content
            } catch {
                state.area.phase = .error("Failed to load \(area).")
            }
        }
    }
    
    // CATEGORY LIST
    private func loadCategory(_ category: String) {
        categoryTask?.cancel()
        state.category = CategoryListState(phase: .loading, category: category, items: [])
        categoryTask = Task {
            do {
                let items = try await repo.getByCategory(category).map { $0.toUI() }
                state.category.items = items
                state.category.phase = items.isEmpty ? .empty : .content
            } catch {
                state.category.phase = .error("Failed to load \(category).")
            }
        }
    }
    
    // SEARCH
    private func debounceSearch() {
        searchDebounceTask?.cancel()
        let q = state.search.query
        searchDebounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 350_000_000) // 350ms
            await self?.search(query: q)
        }
    }
    
    private func search(query: String) {
        searchTask?.cancel()
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            state.search.phase = .idle
            state.search.results = []
            return
        }
        state.search.phase = .loading
        let q = query
        searchTask = Task {
            do {
                let items = try await repo.searchByName(q).map { $0.toUI() }
                state.search.results = items
                state.search.phase = items.isEmpty ? .empty : .content
            } catch {
                state.search.phase = .error("Search failed.")
            }
        }
    }
    
    // DETAIL
    private func loadDetail(_ id: String) {
        detailTask?.cancel()
        state.detail = DetailState(phase: .loading, recipeID: id, item: nil)
        detailTask = Task {
            do {
                let item = try await repo.getRecipeDetail(id: id).toUI()
                state.detail.item = item
                state.detail.phase = .content
            } catch {
                state.detail.phase = .error("Failed to load recipe.")
            }
        }
    }
    
    @MainActor
    private func toggleFavorite(id: String, to newValue: Bool) {
        // Optimistic update across all relevant substates
        func updateInPlace() {
            // home.randomTen
            if let index = state.home.randomTen.firstIndex(where: { $0.id == id }) {
                state.home.randomTen[index].isFavorite = newValue
            }
            // featured
            if state.home.featured?.id == id {
                state.home.featured?.isFavorite = newValue
            }
            // area list
            if let index = state.area.items.firstIndex(where: { $0.id == id }) {
                state.area.items[index].isFavorite = newValue
            }
            // category list
            if let index = state.category.items.firstIndex(where: { $0.id == id }) {
                state.category.items[index].isFavorite = newValue
            }
            // search results
            if let index = state.search.results.firstIndex(where: { $0.id == id }) {
                state.search.results[index].isFavorite = newValue
            }
            // detail
            if state.detail.item?.id == id {
                state.detail.item?.isFavorite = newValue
            }
        }

        // Save old state in case we need to roll back
        let oldState = state

        // 1. Optimistic update
        updateInPlace()

        // 2. Persist asynchronously
        Task {
            do {
                let number = Int64(id)!
                try repo.updateFavorite(id: number, isFavorite: newValue)
            } catch {
                // Roll back on failure
                state = oldState
                print("❌ Failed to update favorite: \(error)")
            }
        }
    }
}

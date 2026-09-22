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
    case setMastered(Bool)
    case setSavingMastered(Bool)
    case setLoadingDetail(Bool)
    case setError(String?)
}

@MainActor
final class DetailViewModel: ObservableObject {
    @Published private(set) var state: DetailState
    private let repo: RecipeRepository
    private var favoriteTask: Task<Void, Never>?
    private var masteryTask: Task<Void, Never>?
    private var detailTask: Task<Void, Never>?

    init( repository: RecipeRepository) {
        self.repo = repository
        self.state = .init()
    }

    deinit {
        favoriteTask?.cancel()
        masteryTask?.cancel()
        detailTask?.cancel()
    }

    func onIntent(_ intent: DetailIntent) {
        switch intent {
        case .setItem(let item):
            setData(item)
        case .loadDetail(let item):
            loadDetail(item)
        case .toggleFavorite:
            toggleFavorite()
        case .toggleMastered:
            toggleMastered()
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
        reduce(.setMastered(repo.isRecipeInList(id: id, type: .mastered)))
        persistIfComplete(reconciledItem)
        recordView(id: id)
    }

    /// Records that the user opened this meal's detail page. Upserted per meal
    /// so the view history stays ordered by the most recent visit.
    private func recordView(id: Int64) {
        do {
            try repo.recordRecipeView(id: id)
        } catch {
            #if DEBUG
            print("❌ recordRecipeView error:", error)
            #endif
        }
    }

    /// Fetches the full record only when the seeded item is a browse-list summary
    /// (`filter.php` returns just id/name/thumb). Complete records (search/random/home)
    /// already carry ingredients + instructions and need no extra request.
    private func loadDetail(_ item: UIRecipeItem) {
        guard item.ingredients.isEmpty, item.instructions.isEmpty else { return }
        guard !item.id.isEmpty else { return }

        detailTask?.cancel()
        reduce(.setLoadingDetail(true))
        detailTask = Task { [weak self] in
            guard let self else { return }
            do {
                let detail = try await repo.getRecipeDetail(id: item.id)
                guard !Task.isCancelled else { return }
                let loaded = detail.toUI().with(isFavorite: repo.isFavourite(id: detail.id))
                reduce(.setItem(loaded))
                persistIfComplete(loaded)
                reduce(.setLoadingDetail(false))
            } catch {
                guard !Task.isCancelled else { return }
                reduce(.setLoadingDetail(false))
                reduce(.setError("Couldn’t load this recipe. Please try again."))
            }
        }
    }

    /// Persists full records only. Saving a summary would poison the local cache
    /// with a recipe that has no ingredients or instructions.
    private func persistIfComplete(_ item: UIRecipeItem) {
        guard !item.ingredients.isEmpty || !item.instructions.isEmpty else { return }
        guard let domainItem = item.toDomain() else { return }

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
        guard let id = Int64(old.id), let domainItem = old.togglingFavorite().toDomain() else {
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
                try repo.setRecipeInList(domainItem, type: .favourite, isIncluded: new.isFavorite)
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

    private func toggleMastered() {
        let item = state.item
        guard let item else { return }
        guard let domainItem = item.toDomain() else {
            reduce(.setError("Invalid recipe id. Please try again."))
            return
        }
        let new = !state.isMastered
        reduce(.setMastered(new))
        reduce(.setSavingMastered(true))

        masteryTask?.cancel()
        masteryTask = Task { [weak self] in
            guard let self else { return }
            do {
                try repo.setRecipeInList(domainItem, type: .mastered, isIncluded: new)
                reduce(.setSavingMastered(false))
            } catch {
                reduce(.setMastered(!new))
                reduce(.setSavingMastered(false))
                reduce(.setError("Failed to update mastered. Please try again."))
                #if DEBUG
                print("❌ toggleMastered error:", error)
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
        case .setMastered(let mastered):
            state.isMastered = mastered
        case .setSavingMastered(let saving):
            state.isSavingMastered = saving
        case .setLoadingDetail(let loading):
            state.isLoadingDetail = loading
        case .setError(let msg):
            state.errorMessage = msg
        }
    }
}

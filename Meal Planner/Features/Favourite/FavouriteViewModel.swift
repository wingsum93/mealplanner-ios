//
//  FavouriteViewModel.swift
//  Meal Planner
//
//  Created by eric ho on 29/8/2025.
//
import Foundation
import Observation

@MainActor
final class FavouriteViewModel: ObservableObject {
    @Published private(set) var favoriteItems: [UIRecipeItem] = []
    @Published var selectedArea: String? = nil
    @Published var selectedCategory: String? = nil
    private let repo: RecipeRepository
    private var task: Task<Void, Never>? = nil

    init(repository: RecipeRepository) {
        self.repo = repository
    }

    deinit { task?.cancel() }

    var availableAreas: [String] {
        let areas = favoriteItems.compactMap { $0.area }.filter { !$0.isEmpty }
        return Array(Set(areas)).sorted()
    }

    var availableCategories: [String] {
        let categories = favoriteItems.compactMap { $0.category }.filter { !$0.isEmpty }
        return Array(Set(categories)).sorted()
    }

    var filteredFavoriteItems: [UIRecipeItem] {
        favoriteItems.filter { item in
            let matchesArea = selectedArea.map { $0 == item.area } ?? true
            let matchesCategory = selectedCategory.map { $0 == item.category } ?? true
            return matchesArea && matchesCategory
        }
    }

    /// Load all favorites (call onAppear of FavouriteScreen)
    func loadFavorites() {
        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await repo.getAllFavoriteRecipes().map { $0.toUI() }
                print("✅ Loaded \(items.count) favorite recipes")
                if !Task.isCancelled {
                    self.favoriteItems = items
                }
            } catch {
                print("❌ Failed to load favorites: \(error)")
                if !Task.isCancelled {
                    self.favoriteItems = []
                }
            }
        }
    }

    /// Toggle favourite state for a given recipe
    func toggleFavorite(_ item: UIRecipeItem) {
        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            do {
                try await repo.updateFavorite(id: Int64(item.id)! , isFavorite: !item.isFavorite)
                // Reload after update to stay in sync
                await self.loadFavorites()
            } catch {
                print("❌ Failed to update favorite: \(error)")
            }
        }
    }
}

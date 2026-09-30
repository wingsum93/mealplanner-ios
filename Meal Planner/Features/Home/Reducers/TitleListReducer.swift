//
//  TitleListReducer.swift
//  Meal Planner
//

import Foundation

/// Owns the three browse lists that share the same shape:
/// recipes filtered by area, by category, and by a single ingredient.
@MainActor
final class TitleListReducer {
    private(set) var area = AreaListState()
    private(set) var category = CategoryListState()
    private(set) var ingredientMeals = IngredientMealsState()

    var onChange: (() -> Void)?

    private let repo: RecipeRepository
    private var areaTask: Task<Void, Never>?
    private var categoryTask: Task<Void, Never>?
    private var ingredientMealsTask: Task<Void, Never>?

    init(repository: RecipeRepository) {
        self.repo = repository
    }

    deinit {
        areaTask?.cancel()
        categoryTask?.cancel()
        ingredientMealsTask?.cancel()
    }

    func loadArea(_ area: String) {
        areaTask?.cancel()
        reduce(.setArea(AreaListState(phase: .loading, area: area, items: [])))
        areaTask = Task { [weak self] in
            guard let self else { return }
            do {
                // Browse-list fetch only (filter.php returns id/name/thumb);
                // full detail is loaded lazily when the user opens a recipe.
                let items = try await repo.getByArea(area).map { $0.toUI() }
                guard !Task.isCancelled else { return }
                reduce(.setAreaItems(items))
            } catch {
                guard !Task.isCancelled else { return }
                reduce(.setAreaPhase(.error("Failed to load \(area).")))
            }
        }
    }

    func loadCategory(_ category: String) {
        categoryTask?.cancel()
        reduce(.setCategory(CategoryListState(phase: .loading, category: category, items: [])))
        categoryTask = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await repo.getByCategory(category).map { $0.toUI() }
                guard !Task.isCancelled else { return }
                reduce(.setCategoryItems(items))
            } catch {
                guard !Task.isCancelled else { return }
                reduce(.setCategoryPhase(.error("Failed to load \(category).")))
            }
        }
    }

    func loadIngredientMeals(_ ingredient: String) {
        ingredientMealsTask?.cancel()
        reduce(.setIngredientMeals(IngredientMealsState(phase: .loading, ingredient: ingredient, items: [])))
        ingredientMealsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await repo.getBySingleIngredient(ingredient).map { $0.toUI() }
                guard !Task.isCancelled else { return }
                reduce(.setIngredientMealsItems(items))
            } catch {
                guard !Task.isCancelled else { return }
                reduce(.setIngredientMealsPhase(.error("Failed to load \(ingredient).")))
            }
        }
    }

    private enum Event {
        case setArea(AreaListState)
        case setAreaItems([UIRecipeItem])
        case setAreaPhase(LoadPhase)
        case setCategory(CategoryListState)
        case setCategoryItems([UIRecipeItem])
        case setCategoryPhase(LoadPhase)
        case setIngredientMeals(IngredientMealsState)
        case setIngredientMealsItems([UIRecipeItem])
        case setIngredientMealsPhase(LoadPhase)
    }

    private func reduce(_ event: Event) {
        switch event {
        case .setArea(let area):
            self.area = area
        case .setAreaItems(let items):
            area.items = items
            area.phase = items.isEmpty ? .empty : .content
        case .setAreaPhase(let phase):
            area.phase = phase
        case .setCategory(let category):
            self.category = category
        case .setCategoryItems(let items):
            category.items = items
            category.phase = items.isEmpty ? .empty : .content
        case .setCategoryPhase(let phase):
            category.phase = phase
        case .setIngredientMeals(let meals):
            ingredientMeals = meals
        case .setIngredientMealsItems(let items):
            ingredientMeals.items = items
            ingredientMeals.phase = items.isEmpty ? .empty : .content
        case .setIngredientMealsPhase(let phase):
            ingredientMeals.phase = phase
        }
        onChange?()
    }
}

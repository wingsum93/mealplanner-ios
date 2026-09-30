//
//  HomeReducer.swift
//  Meal Planner
//

import Foundation

/// Owns the home screen slice and the ingredient list slice it populates.
@MainActor
final class HomeReducer {
    private(set) var home = HomeState()
    private(set) var ingredients = IngredientListState()

    var onChange: (() -> Void)?

    private let repo: RecipeRepository
    private var homeTask: Task<Void, Never>?
    private var ingredientsTask: Task<Void, Never>?

    init(repository: RecipeRepository) {
        self.repo = repository
    }

    deinit {
        homeTask?.cancel()
        ingredientsTask?.cancel()
    }

    func loadHome() {
        homeTask?.cancel()
        reduce(.setHomePhase(.loading))
        homeTask = Task { [weak self] in
            guard let self else { return }
            async let areas       = repo.getAllArea()
            async let categories  = repo.getAllCategory()
            async let ingredients = repo.getAllIngredients()
            async let randomBatch = repo.getRandom10Recipe()

            // Partial tolerance: a single failing section must not blank the whole home.
            let areasResult       = try? await areas
            let categoriesResult  = try? await categories
            let ingredientsResult = try? await ingredients
            let randomResult      = try? await randomBatch

            guard !Task.isCancelled else { return }

            if areasResult == nil && categoriesResult == nil
                && ingredientsResult == nil && randomResult == nil {
                reduce(.setHomePhase(.error("Couldn’t load home. Pull to retry.")))
                return
            }

            let randomTen = (randomResult ?? []).map { $0.toUI() }.dedupedByID()
            reduce(.setHomeContent(
                featured: randomTen.first,
                areas: areasResult ?? [],
                categories: categoriesResult ?? [],
                randomTen: randomTen
            ))
            reduce(.setHomeIngredients(ingredientsResult ?? []))
        }
    }

    func loadIngredients() {
        ingredientsTask?.cancel()
        reduce(.setIngredientsPhase(.loading))
        ingredientsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await repo.getAllIngredients()
                guard !Task.isCancelled else { return }
                reduce(.setIngredients(items))
            } catch {
                guard !Task.isCancelled else { return }
                reduce(.setIngredientsPhase(.error("Failed to load ingredients.")))
            }
        }
    }

    private enum Event {
        case setHomePhase(LoadPhase)
        case setHomeContent(featured: UIRecipeItem?, areas: [String], categories: [String], randomTen: [UIRecipeItem])
        case setHomeIngredients([Ingredient])
        case setIngredients([Ingredient])
        case setIngredientsPhase(LoadPhase)
    }

    private func reduce(_ event: Event) {
        switch event {
        case .setHomePhase(let phase):
            home.phase = phase
        case .setHomeContent(let featured, let areas, let categories, let randomTen):
            home.featured = featured
            home.areas = areas
            home.categories = categories
            home.randomTen = randomTen
            let hasContent = featured != nil || !areas.isEmpty || !categories.isEmpty || !randomTen.isEmpty
            home.phase = hasContent ? .content : .empty
        case .setHomeIngredients(let items):
            ingredients.items = items
            ingredients.phase = items.isEmpty ? .empty : .content
        case .setIngredients(let items):
            ingredients.items = items
            ingredients.phase = items.isEmpty ? .empty : .content
        case .setIngredientsPhase(let phase):
            ingredients.phase = phase
        }
        onChange?()
    }
}

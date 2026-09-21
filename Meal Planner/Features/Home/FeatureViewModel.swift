//
//  HomeViewModel.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import Foundation
import Combine

/// Composition root for the browse/search feature. Each concern has its own
/// reducer (state + tasks); this facade assembles their slices into a single
/// `FeatureState` and routes intents, so views keep one observable object.
@MainActor
final class FeatureViewModel: ObservableObject {
    private let homeReducer: HomeReducer
    private let titleListReducer: TitleListReducer
    private let searchReducer: SearchReducer
    private let randomPickReducer: RandomPickReducer

    var state: FeatureState {
        FeatureState(
            home: homeReducer.home,
            area: titleListReducer.area,
            category: titleListReducer.category,
            search: searchReducer.state,
            randomPick: randomPickReducer.state,
            ingredients: homeReducer.ingredients,
            ingredientMeals: titleListReducer.ingredientMeals
        )
    }

    init(
        repository: RecipeRepository,
        searchDebounceDelay: UInt64 = SearchReducer.defaultSearchDebounceDelay
    ) {
        let homeReducer = HomeReducer(repository: repository)
        let titleListReducer = TitleListReducer(repository: repository)
        let searchReducer = SearchReducer(
            repository: repository,
            searchDebounceDelay: searchDebounceDelay
        )
        let randomPickReducer = RandomPickReducer(repository: repository)

        self.homeReducer = homeReducer
        self.titleListReducer = titleListReducer
        self.searchReducer = searchReducer
        self.randomPickReducer = randomPickReducer

        let notify: () -> Void = { [weak self] in
            self?.objectWillChange.send()
        }
        homeReducer.onChange = notify
        titleListReducer.onChange = notify
        searchReducer.onChange = notify
        randomPickReducer.onChange = notify
    }

    func onIntent(_ intent: HomeIntent) {
        switch intent {
            // MARK: Home
        case .loadHome, .refreshHome:
            homeReducer.loadHome()
        case .loadIngredients:
            homeReducer.loadIngredients()

            // MARK: Lists
        case .loadArea(let area):
            titleListReducer.loadArea(area)
        case .loadCategory(let category):
            titleListReducer.loadCategory(category)
        case .loadIngredientMeals(let ingredient):
            titleListReducer.loadIngredientMeals(ingredient)

            // MARK: Search
        case .updateQuery(let q):
            searchReducer.updateQuery(q)
        case .performSearch:
            searchReducer.performSearch()
        case .updateSearchFavorite(let id, let isFavorite):
            searchReducer.updateFavorite(id: id, isFavorite: isFavorite)

            // MARK: Random pick
        case .loadRandomPick:
            randomPickReducer.load()
        case .updateRandomPickItems(let items):
            randomPickReducer.updateItems(items)
        }
    }
}

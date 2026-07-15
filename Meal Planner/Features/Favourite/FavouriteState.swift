//
//  FavouriteState.swift
//  Meal Planner
//
//  Created by eric ho on 29/8/2025.
//

struct FavouriteState: Equatable {
    var phase: LoadPhase = .idle
    var items: [UIRecipeItem] = []
    var selectedArea: String?
    var selectedCategory: String?
    var errorMessage: String?

    var availableAreas: [String] {
        let areas = items.compactMap { $0.area }.filter { !$0.isEmpty }
        return Array(Set(areas)).sorted()
    }

    var availableCategories: [String] {
        let categories = items.compactMap { $0.category }.filter { !$0.isEmpty }
        return Array(Set(categories)).sorted()
    }

    var filteredItems: [UIRecipeItem] {
        items.filter { item in
            let matchesArea = selectedArea.map { $0 == item.area } ?? true
            let matchesCategory = selectedCategory.map { $0 == item.category } ?? true
            return matchesArea && matchesCategory
        }
    }
}

//
//  MyListState.swift
//  Meal Planner
//
//  Created by eric ho on 22/9/2026.
//

struct MyListState: Equatable {
    var selectedList: RecipeListType = .favourite
    var phase: LoadPhase = .idle
    var items: [UIRecipeItem] = []
    var selectedArea: String?
    var selectedCategory: String?
    var errorMessage: String?

    /// Favourite and Mastered expose the area/category filters; the view history
    /// is always ordered by date and cannot be filtered.
    var showsFilters: Bool {
        selectedList.supportsFiltering
    }

    var availableAreas: [String] {
        let areas = items.compactMap { $0.area }.filter { !$0.isEmpty }
        return Array(Set(areas)).sorted()
    }

    var availableCategories: [String] {
        let categories = items.compactMap { $0.category }.filter { !$0.isEmpty }
        return Array(Set(categories)).sorted()
    }

    var filteredItems: [UIRecipeItem] {
        guard showsFilters else { return items }
        return items.filter { item in
            let matchesArea = selectedArea.map { $0 == item.area } ?? true
            let matchesCategory = selectedCategory.map { $0 == item.category } ?? true
            return matchesArea && matchesCategory
        }
    }

    var emptyMessage: String {
        switch selectedList {
        case .favourite:
            return "You have not bookmarked yet."
        case .mastered:
            return "You have not mastered any meal yet."
        case .viewed:
            return "You have not viewed any meal yet."
        }
    }
}

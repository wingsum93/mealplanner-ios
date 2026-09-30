//
//  MyListState.swift
//  Meal Planner
//
//  Created by eric ho on 22/9/2026.
//

struct MyListState: Equatable {
    var selectedList: RecipeListType = .favourite {
        didSet { refreshDerivedData() }
    }
    var phase: LoadPhase = .idle
    var items: [UIRecipeItem] = [] {
        didSet { refreshDerivedData() }
    }
    var selectedArea: String? {
        didSet { refreshDerivedData() }
    }
    var selectedCategory: String? {
        didSet { refreshDerivedData() }
    }
    var errorMessage: String?
    private(set) var availableAreas: [String] = []
    private(set) var availableCategories: [String] = []
    private(set) var filteredItems: [UIRecipeItem] = []

    init(
        selectedList: RecipeListType = .favourite,
        phase: LoadPhase = .idle,
        items: [UIRecipeItem] = [],
        selectedArea: String? = nil,
        selectedCategory: String? = nil,
        errorMessage: String? = nil
    ) {
        self.selectedList = selectedList
        self.phase = phase
        self.items = items
        self.selectedArea = selectedArea
        self.selectedCategory = selectedCategory
        self.errorMessage = errorMessage
        refreshDerivedData()
    }

    /// Favourite and Mastered expose the area/category filters; the view history
    /// is always ordered by date and cannot be filtered.
    var showsFilters: Bool {
        selectedList.supportsFiltering
    }

    private mutating func refreshDerivedData() {
        let areas = items.compactMap { $0.area }.filter { !$0.isEmpty }
        let categories = items.compactMap { $0.category }.filter { !$0.isEmpty }
        availableAreas = Array(Set(areas)).sorted()
        availableCategories = Array(Set(categories)).sorted()

        guard showsFilters else {
            filteredItems = items
            return
        }

        filteredItems = items.filter { item in
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

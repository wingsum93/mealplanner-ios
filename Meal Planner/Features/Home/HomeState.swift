//
//  HomeScreenState.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

enum Phase: Equatable { case idle, loading, content, empty, error(String) }

struct HomeState: Equatable {
  var phase: Phase = .idle
  var featured: UIRecipeItem?
  var areas: [String] = []
  var categories: [String] = []
  var randomTen: [UIRecipeItem] = []
}

struct AreaListState: Equatable {
  var phase: Phase = .idle
  var area: String = ""
  var items: [UIRecipeItem] = []
}

struct CategoryListState: Equatable {
  var phase: Phase = .idle
  var category: String = ""
  var items: [UIRecipeItem] = []
}

struct SearchState: Equatable {
  var phase: Phase = .idle
  var query: String = ""
  var results: [UIRecipeItem] = []
}

struct DetailState: Equatable {
  var phase: Phase = .idle
  var recipeID: String = ""
  var item: UIRecipeItem?
}

enum Route: Hashable {
  case area(String)
  case category(String)
  case search
  case detail(String)
}

struct FeatureState: Equatable {
  var home = HomeState()
  var area = AreaListState()
  var category = CategoryListState()
  var search = SearchState()
  var detail = DetailState()
  var path: [Route] = []             // NavigationStack path
  var selectedMatchedID: String? = nil // for hero animation
}


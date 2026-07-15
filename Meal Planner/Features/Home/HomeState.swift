//
//  HomeScreenState.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

enum LoadPhase: Equatable {
    case idle
    case loading
    case content
    case empty
    case error(String)
}

struct HomeState: Equatable {
  var phase: LoadPhase = .idle
  var featured: UIRecipeItem?
  var areas: [String] = []
  var categories: [String] = []
  var randomTen: [UIRecipeItem] = []
}

struct AreaListState: Equatable {
  var phase: LoadPhase = .idle
  var area: String = ""
  var items: [UIRecipeItem] = []
}

struct CategoryListState: Equatable {
  var phase: LoadPhase = .idle
  var category: String = ""
  var items: [UIRecipeItem] = []
}

struct SearchState: Equatable {
  var phase: LoadPhase = .idle
  var query: String = ""
  var results: [UIRecipeItem] = []
}

struct RandomPickState: Equatable {
  var phase: LoadPhase = .idle
  var items: [UIRecipeItem] = []
}

enum FeatureRoute: Hashable {
  case area(String)
  case category(String)
  case search
  case randomPick
}

struct FeatureState: Equatable {
  var home = HomeState()
  var area = AreaListState()
  var category = CategoryListState()
  var search = SearchState()
  var randomPick = RandomPickState()
  var path: [FeatureRoute] = []             // NavigationStack path
  
}

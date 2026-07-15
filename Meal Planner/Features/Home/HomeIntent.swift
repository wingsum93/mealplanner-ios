//
//  HomeIntent.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

enum HomeIntent {
    // navigation
    case goToArea(String)
    case goToCategory(String)
    case goToSearch
    case goToRandomPick
    case pop
    case replacePath([Route])
    
    // home
    case loadHome
    case refreshHome
    case loadRandomPick
    case updateRandomPickItems([UIRecipeItem])
    
    // lists
    case loadArea(String)
    case loadCategory(String)
    
    // search
    case updateQuery(String)
    case performSearch
    case updateSearchFavorite(id: String, isFavorite: Bool)
    
}

enum FeatureEvent: Equatable {
    case setPath([Route])
    case pushRoute(Route)
    case popRoute
    case setHomePhase(Phase)
    case setHomeContent(featured: UIRecipeItem?, areas: [String], categories: [String], randomTen: [UIRecipeItem])
    case setArea(AreaListState)
    case setAreaItems([UIRecipeItem])
    case setAreaPhase(Phase)
    case setCategory(CategoryListState)
    case setCategoryItems([UIRecipeItem])
    case setCategoryPhase(Phase)
    case setSearchQuery(String)
    case setSearchPhase(Phase)
    case setSearchResults([UIRecipeItem])
    case setSearchFavorite(id: String, isFavorite: Bool)
    case resetSearch
    case setRandomPickPhase(Phase)
    case setRandomPickItems([UIRecipeItem])
}

//
//  HomeIntent.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

enum HomeIntent {
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

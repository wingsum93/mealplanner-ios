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
    case goToDetail(String)
    case pop
    
    // home
    case loadHome
    case refreshHome
    
    // lists
    case loadArea(String)
    case loadCategory(String)
    
    // search
    case updateQuery(String)
    case performSearch
    
    // detail
    case loadDetail(String)
    case toggleFavorite(id: String, isFavorite: Bool)
}

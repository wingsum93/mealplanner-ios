//
//  HomeScreenState.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI

struct HomeScreenState {
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    // Data loaded from APIs
    var randomRecipe: UIRecipeItem? = nil
    var areaList: [String] = []
    var categoryList: [String] = []
    var beefRecipes: [UIRecipeItem] = []
    

    static let initial = HomeScreenState()
}


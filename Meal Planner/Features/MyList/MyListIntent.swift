//
//  MyListIntent.swift
//  Meal Planner
//
//  Created by eric ho on 22/9/2026.
//

enum MyListIntent {
    case loadList(RecipeListType)
    case selectList(RecipeListType)
    case selectArea(String?)
    case selectCategory(String?)
    case toggleFavorite(UIRecipeItem)
    case toggleMastered(UIRecipeItem)
    case clearError
}

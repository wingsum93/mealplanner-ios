//
//  RecipeItemDisplay.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import Foundation

struct UIRecipeItem: Identifiable, Equatable,Hashable {
    let id: String
    let name: String
    let area: String?
    let category: String?
    let thumbURL: URL?
    let isFavorite: Bool
}

extension UIRecipeItem {
    static let sample = UIRecipeItem(
        id: "sample-1",
        name: "Blini Pancakes",
        area: "hk",
        category: "burger",
        thumbURL: URL(string: "https://www.themealdb.com/images/media/meals/rwuyqx1511383174.jpg"),
        isFavorite: false
    )
}

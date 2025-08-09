//
//  RecipeItemDisplay.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import Foundation

struct UIRecipeItem: Identifiable, Equatable {
    let id: String
    let title: String
    let imageUrl: String
    let duration: String   // e.g. "20 Mins"
    let rating: Int        // e.g. 3 stars

    // Optional extras
    let difficulty: String?  // e.g. "Easy"
    let isFavorite: Bool     // used for display purposes

    init(
        id: String,
        title: String,
        imageUrl: String,
        duration: String = "20 Mins",
        rating: Int = 3,
        difficulty: String? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.duration = duration
        self.rating = rating
        self.difficulty = difficulty
        self.isFavorite = isFavorite
    }
}

extension UIRecipeItem {
    static let sample = UIRecipeItem(
        id: "sample-1",
        title: "Blini Pancakes",
        imageUrl: "https://www.themealdb.com/images/media/meals/rwuyqx1511383174.jpg",
        duration: "20 Mins",
        rating: 4,
        difficulty: "Easy"
    )
}

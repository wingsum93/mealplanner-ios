//
//  RecipeItem.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

struct RecipeItem: Identifiable, Equatable {
    let id: Int64
    let title: String
    let description: String
    let category: String
    let area: String
    let imageUrl: String
    let youtubeLink: String
    let ingredients: [String]
    let measures: [String]
    let instructions: [String]
    let tags: [String]
    let isFavorite: Bool
    let rating: Int64
}


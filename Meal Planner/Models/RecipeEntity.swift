//
//  RecipeEntity.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftData

@Model
final class RecipeEntity {
    var id: Int64
    var title: String
    var des: String
    var category: String
    var area: String
    var imageUrl: String
    var youtubeLink: String
    var ingredients: [String]
    var instructions: [String]
    var isFavorite: Bool
    var rating: Int64

    init(
        id: Int64,
        title: String,
        description: String,
        category: String,
        area: String,
        imageUrl: String,
        youtubeLink: String,
        ingredients: [String],
        instructions: [String],
        isFavorite: Bool,
        rating: Int64
    ) {
        self.id = id
        self.title = title
        self.des = description
        self.category = category
        self.area = area
        self.imageUrl = imageUrl
        self.youtubeLink = youtubeLink
        self.ingredients = ingredients
        self.instructions = instructions
        self.isFavorite = isFavorite
        self.rating = rating
    }
}

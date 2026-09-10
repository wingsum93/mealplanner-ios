//
//  UIRecipeItemExtension.swift
//  Meal Planner
//
//  Created by eric ho on 17/8/2025.
//

extension UIRecipeItem {
    func with(isFavorite: Bool) -> UIRecipeItem {
        .init(
            id: id,
            name: name,
            description: description,
            area: area,
            category: category,
            thumbURL: thumbURL,
            ingredients: ingredients,
            measures: measures,
            instructions: instructions,
            tags: tags,
            youtubeLink: youtubeLink,
            isFavorite: isFavorite)
    }
    func togglingFavorite() -> UIRecipeItem {
        with(isFavorite: !isFavorite)
    }
}


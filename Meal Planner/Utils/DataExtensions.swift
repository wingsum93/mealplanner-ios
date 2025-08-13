//
//  Extensions.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import Foundation

extension RecipeEntity {
    func toDomain() -> RecipeItem {
        RecipeItem(
            id: id,
            title: title,
            description: des,
            category: category,
            area: area,
            imageUrl: imageUrl,
            youtubeLink: youtubeLink,
            ingredients: ingredients,
            instructions: instructions,
            isFavorite: isFavorite,
            rating: rating
        )
    }
}

extension RecipeItem {
    func toEntity() -> RecipeEntity {
        RecipeEntity(
            id: id,
            title: title,
            description: description,
            category: category,
            area: area,
            imageUrl: imageUrl,
            youtubeLink: youtubeLink,
            ingredients: ingredients,
            instructions: instructions,
            isFavorite: isFavorite,
            rating: rating
        )
    }
    
    func toUI() -> UIRecipeItem {
        UIRecipeItem(
            id: String(id),
            name: title,
            area: area,
            category: category,
            thumbURL: URL(string: imageUrl),
            isFavorite: isFavorite
        )
    }
}

extension RecipeItemDto {
    func toDomain() -> RecipeItem {
        guard let idInt = Int64(idMeal ?? "") else {
            fatalError("Invalid idMeal: \(idMeal ?? "nil")")
        }
        
        let ingredientPairs: [String?] = [
            combineIngredient(strIngredient1, strMeasure1),
            combineIngredient(strIngredient2, strMeasure2),
            combineIngredient(strIngredient3, strMeasure3),
            combineIngredient(strIngredient4, strMeasure4),
            combineIngredient(strIngredient5, strMeasure5),
            combineIngredient(strIngredient6, strMeasure6),
            combineIngredient(strIngredient7, strMeasure7),
            combineIngredient(strIngredient8, strMeasure8),
            combineIngredient(strIngredient9, strMeasure9),
            combineIngredient(strIngredient10, strMeasure10),
            combineIngredient(strIngredient11, strMeasure11),
            combineIngredient(strIngredient12, strMeasure12),
            combineIngredient(strIngredient13, strMeasure13),
            combineIngredient(strIngredient14, strMeasure14),
            combineIngredient(strIngredient15, strMeasure15),
            combineIngredient(strIngredient16, strMeasure16),
            combineIngredient(strIngredient17, strMeasure17),
            combineIngredient(strIngredient18, strMeasure18),
            combineIngredient(strIngredient19, strMeasure19),
            combineIngredient(strIngredient20, strMeasure20)
        ]
        let ingredients = ingredientPairs.compactMap { $0 }
        
        let cleanedInstructions = strInstructions?
            .components(separatedBy: ".")
            .map { $0.replacingOccurrences(of: "\r\n", with: "").trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { $0.capitalizingFirstLetter() } ?? []
        
        return RecipeItem(
            id: Int64(idInt),
            title: strMeal ?? "",
            description: strMeal ?? "",
            category: strCategory ?? "",
            area: strArea ?? "",
            imageUrl: strMealThumb ?? "",
            youtubeLink: strYoutube ?? "",
            ingredients: ingredients,
            instructions: cleanedInstructions,
            isFavorite: false,
            rating: 3
        )
    }
    
    private func combineIngredient(_ ingredient: String?, _ measure: String?) -> String? {
        let trimmedIngredient = ingredient?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let i = trimmedIngredient, !i.isEmpty {
            return "\(i):\(measure ?? "")"
        }
        return nil
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }
}

extension IngredientDto {
    func toEntity() -> IngredientEntity? {
        guard
            let idString = idIngredient,
            let id = Int64(idString),
            let name = strIngredient
        else {
            return nil
        }
        
        return IngredientEntity(
            id: id,
            name: name,
            descriptionText: strDescription,
            type: strType
        )
    }
    func toDomain() -> Ingredient? {
        guard
            let idStr = idIngredient,
            let id = Int(idStr),
            let name = strIngredient
        else {
            return nil
        }
        
        return Ingredient(
            id: id,
            name: name,
            descriptionText: strDescription,
            type: strType
        )
    }
}

extension Ingredient {
    func toEntity() -> IngredientEntity {
        IngredientEntity(
            id: Int64(id),
            name: name,
            descriptionText: descriptionText,
            type: type
        )
    }
}
extension IngredientEntity {
    func toDomain() -> Ingredient {
        Ingredient(
            id: Int(id),
            name: name,
            descriptionText: descriptionText,
            type: type
        )
    }
}



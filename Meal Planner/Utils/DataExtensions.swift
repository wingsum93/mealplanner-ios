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
            ingredients: ingredients,
            isFavorite: isFavorite
        )
    }
}

extension RecipeItemDto {
    func toDomain() -> RecipeItem {
        guard let idInt = Int64(idMeal ?? "") else {
            fatalError("Invalid idMeal: \(idMeal ?? "nil")")
        }
        
        let ingredients = toSafeStringList( strIngredient1,
                                       strIngredient2,
                                       strIngredient3,
                                       strIngredient4,
                                       strIngredient5,
                                       strIngredient6,
                                       strIngredient7,
                                       strIngredient8,
                                       strIngredient9,
                                       strIngredient10,
                                       strIngredient11,
                                       strIngredient12,
                                       strIngredient13,
                                       strIngredient14,
                                       strIngredient15,
                                       strIngredient16,
                                       strIngredient17,
                                       strIngredient18,
                                       strIngredient19,
                                       strIngredient20)
        
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
    private func toSafeStringList(_ input: String?...) -> [String] {
        input.compactMap { item in
            // trim 掉前後空格，如果結果為空就排除
            if let trimmed = item?.trimmingCharacters(in: .whitespacesAndNewlines),
               !trimmed.isEmpty {
                return trimmed
            }
            return nil
        }
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



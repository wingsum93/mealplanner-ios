//
//  IngredientEntity.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//
import Foundation
import SwiftData

@Model
final class IngredientEntity {
    var id: Int64
    var name: String
    var descriptionText: String?
    var type: String?

    init(
        id: Int64,
        name: String,
        descriptionText: String?,
        type: String?
    ) {
        self.id = id
        self.name = name
        self.descriptionText = descriptionText
        self.type = type
    }
}


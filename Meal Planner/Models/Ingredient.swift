//
//  Ingredient.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//
import Foundation

struct Ingredient: Identifiable, Equatable {
    let id: Int
    let name: String
    let descriptionText: String?
    let type: String?
}


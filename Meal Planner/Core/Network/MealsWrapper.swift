//
//  MealsWrapper.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//

struct MealsWrapper<T: Decodable>: Decodable {
    let meals: [T]?
}

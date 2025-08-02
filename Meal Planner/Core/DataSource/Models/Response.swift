//
//  Response.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

struct RecipeItemListResponse: Decodable {
    let meals: [RecipeItemDto]
}

struct RecipeItemSingleResponse: Decodable {
    let meals: [RecipeItemDto]?
}

struct CategoryResponse: Decodable {
    let meals: [CategoryWrapper]
}

struct CategoryWrapper: Decodable {
    let strCategory: String
}

struct AreaResponse:Decodable{
    let meals: [AreaWrapper]
}

struct AreaWrapper: Decodable {
    let strArea: String
}

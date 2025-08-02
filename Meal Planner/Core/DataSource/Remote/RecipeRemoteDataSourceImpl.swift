//
//  RecipeRemoteDataSourceImpl.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import Foundation
import Alamofire

final class RecipeRemoteDataSourceImpl: RecipeRemoteDataSource {

    // my v2 api key -> 65232507
    private let baseURL = "www.themealdb.com/api/json/v2"+"65232507/"

    func getAllIngredients() async throws -> [IngredientDto] {
        let url = "\(baseURL)/list.php?i=list"
        return try await withCheckedThrowingContinuation { continuation in
                AF.request(url)
                    .validate()
                    .responseDecodable(of: IngredientResponse.self) { response in
                        switch response.result {
                        case .success(let result):
                            continuation.resume(returning: result.meals)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
        }
    }

    func getAllCategory() async throws -> [String] {
        let url = "\(baseURL)/list.php?c=list"
        return try await withCheckedThrowingContinuation { continuation in
                AF.request(url)
                    .validate()
                    .responseDecodable(of: CategoryResponse.self) { response in
                        switch response.result {
                        case .success(let result):
                            let categories = result.meals.map { $0.strCategory }
                            continuation.resume(returning: categories)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
        }
    }

    func getAllArea() async throws -> [String] {
        let url = "\(baseURL)/list.php?a=list"
        return try await withCheckedThrowingContinuation { continuation in
                AF.request(url)
                    .validate()
                    .responseDecodable(of: AreaResponse.self) { response in
                        switch response.result {
                        case .success(let result):
                            let categories = result.meals.map { $0.strArea }
                            continuation.resume(returning: categories)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
        }
    }

    func getBySingleIngredient(_ ingredient: String) async throws -> [RecipeItemDto] {
        let url = "\(baseURL)/filter.php?i=\(ingredient.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ingredient)"
        return try await requestList(from: url)
    }

    func getByCategory(_ category: String) async throws -> [RecipeItemDto] {
        let url = "\(baseURL)/filter.php?c=\(category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? category)"
        return try await requestList(from: url)
    }
    func getByArea(_ area: String) async throws -> [RecipeItemDto] {
        let url = "\(baseURL)/filter.php?a=\(area.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? area)"
        return try await requestList(from: url)
    }

    func searchByName(_ keyword: String) async throws -> [RecipeItemDto] {
        let url = "\(baseURL)/search.php?s=\(keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword)"
        return try await requestList(from: url)
    }

    func getRecipeDetail(id: String) async throws -> RecipeItemDto? {
        let url = "\(baseURL)/lookup.php?i=\(id)"
        return try await requestSingle(from: url)
    }

    func getRandomRecipe() async throws -> RecipeItemDto {
        let url = "\(baseURL)/random"
        guard let recipe = try await requestSingle(from: url) else {
            throw URLError(.badServerResponse)
        }
        return recipe
    }
    
    func getRandom10Recipe() async throws -> [RecipeItemDto] {
        let url = "\(baseURL)/randomselection.php"
        return try await requestList(from: url)
    }

    // MARK: - Helper Methods

    private func requestList(from url: String) async throws -> [RecipeItemDto] {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(url)
                .validate()
                .responseDecodable(of: RecipeItemListResponse.self) { response in
                    switch response.result {
                    case .success(let wrapper):
                        continuation.resume(returning: wrapper.meals)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    private func requestSingle(from url: String) async throws -> RecipeItemDto? {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(url)
                .validate()
                .responseDecodable(of: RecipeItemSingleResponse.self) { response in
                    switch response.result {
                    case .success(let wrapper):
                        continuation.resume(returning: wrapper.meals?.first)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}

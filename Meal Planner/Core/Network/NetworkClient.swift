//
//  NetworkClient.swift
//  Meal Planner
//
//  Created by eric ho on 9/8/2025.
//

protocol NetworkClient {
    func request<T: Decodable>(
        url: String,
        type: T.Type
    ) async throws -> T

    func requestList<T: Decodable>(
        url: String,
        elementType: T.Type
    ) async throws -> [T]

    func requestFirst<T: Decodable>(
        url: String,
        elementType: T.Type
    ) async throws -> T?
}

//
//  NetworkClient.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import Foundation
import Alamofire

final class AlamofireNetworkClient:NetworkClient {

    func request<T: Decodable>(
        url: String,
        type: T.Type = T.self
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(url)
                .validate()
                .responseDecodable(of: type) { response in
                    switch response.result {
                    case .success(let result):
                        continuation.resume(returning: result)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    func requestList<T: Decodable>(
        url: String,
        elementType: T.Type = T.self
    ) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(url)
                .validate()
                .responseDecodable(of: MealsWrapper<T>.self) { response in
                    switch response.result {
                    case .success(let wrapper):
                        continuation.resume(returning: wrapper.meals ?? [])
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    func requestFirst<T: Decodable>(
        url: String,
        elementType: T.Type = T.self
    ) async throws -> T? {
        let list: [T] = try await requestList(url: url, elementType: elementType)
        return list.first
    }
}


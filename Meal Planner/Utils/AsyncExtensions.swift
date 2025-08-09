//
//  AsyncExtensions.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//

extension Range<Int> {
    func asyncCompactMap<T>(_ transform: @escaping (Int) async throws -> T?) async -> [T] {
        await withTaskGroup(of: T?.self) { group in
            for i in self {
                group.addTask { try? await transform(i) }
            }

            var results: [T] = []
            for await item in group {
                if let item = item {
                    results.append(item)
                }
            }
            return results
        }
    }
}

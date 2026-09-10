//
//  AppRouter.swift
//  Meal Planner
//
//  Created by Codex on 15/7/2026.
//

import Combine

@MainActor
final class AppRouter: ObservableObject {
    @Published var path: [FeatureRoute] = []
    @Published var activeSheet: AppSheet?
    @Published var activeFullScreenCover: AppFullScreenCover?

    func push(_ route: FeatureRoute) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty {
            _ = path.removeLast()
        }
    }

    func replacePath(_ path: [FeatureRoute]) {
        self.path = path
    }

    func presentRecipeDetail(_ item: UIRecipeItem) {
        activeSheet = .recipeDetail(item)
    }

    func dismissSheet() {
        activeSheet = nil
    }

    func presentRandomPick() {
        activeFullScreenCover = .randomPick
    }

    func dismissFullScreenCover() {
        activeFullScreenCover = nil
    }
}

enum AppSheet: Identifiable, Equatable {
    case recipeDetail(UIRecipeItem)

    var id: String {
        switch self {
        case .recipeDetail(let item):
            return "recipeDetail-\(item.id)"
        }
    }
}

enum AppFullScreenCover: String, Identifiable, Equatable {
    case randomPick

    var id: String {
        rawValue
    }
}

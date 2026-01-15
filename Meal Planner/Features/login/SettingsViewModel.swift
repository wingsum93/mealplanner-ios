//
//  SettingsViewModel.swift
//  Meal Planner
//
//  Created by eric ho on 5/8/2025.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    private let localDataSource: RecipeLocalDataSource

    init(localDataSource: RecipeLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func clearCachedRecipes() throws {
        try localDataSource.clearCachedRecipes()
    }

    func resetFavorites() throws {
        try localDataSource.resetFavorites()
    }
}

//
//  SettingsViewModel.swift
//  Meal Planner
//
//  Created by eric ho on 5/8/2025.
//

import Foundation

private enum SettingsEvent: Equatable {
    case setSummary(SettingsDataSummary)
    case setShowLargeMealPage(Bool)
    case setStatus(String?)
    case setError(String?)
}

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var state = SettingsState()
    private let localDataSource: RecipeLocalDataSource
    private let userDefaults: UserDefaults
    private let onFavoritesReset: @MainActor () -> Void

    init(
        localDataSource: RecipeLocalDataSource,
        userDefaults: UserDefaults = .standard,
        onFavoritesReset: @escaping @MainActor () -> Void = {}
    ) {
        self.localDataSource = localDataSource
        self.userDefaults = userDefaults
        self.onFavoritesReset = onFavoritesReset
        state.showLargeMealPage = userDefaults.bool(forKey: SettingsDefaultsKey.showLargeMealPage)
        loadSummary()
    }

    func onIntent(_ intent: SettingsIntent) {
        switch intent {
        case .loadSummary:
            loadSummary()
        case .perform(let action):
            perform(action)
        case .setShowLargeMealPage(let isEnabled):
            userDefaults.set(isEnabled, forKey: SettingsDefaultsKey.showLargeMealPage)
            reduce(.setShowLargeMealPage(isEnabled))
        case .clearStatus:
            reduce(.setStatus(nil))
            reduce(.setError(nil))
        }
    }

    private func loadSummary() {
        do {
            let summary = try localDataSource.getSettingsDataSummary()
            reduce(.setSummary(summary))
            reduce(.setError(nil))
        } catch {
            reduce(.setError(error.localizedDescription))
        }
    }

    private func perform(_ action: SettingsAction) {
        do {
            switch action {
            case .clearBrowseCache:
                try localDataSource.clearBrowseCachePreservingFavorites()
            case .clearLookupCaches:
                try localDataSource.clearLookupCaches()
            case .resetFavorites:
                try localDataSource.resetFavorites()
                onFavoritesReset()
            }
            let summary = try localDataSource.getSettingsDataSummary()
            reduce(.setSummary(summary))
            reduce(.setStatus(action.successMessage))
            reduce(.setError(nil))
        } catch {
            reduce(.setStatus(nil))
            reduce(.setError(error.localizedDescription))
        }
    }

    private func reduce(_ event: SettingsEvent) {
        switch event {
        case .setSummary(let summary):
            state.summary = summary
        case .setShowLargeMealPage(let isEnabled):
            state.showLargeMealPage = isEnabled
        case .setStatus(let message):
            state.statusMessage = message
        case .setError(let message):
            state.errorMessage = message
        }
    }
}

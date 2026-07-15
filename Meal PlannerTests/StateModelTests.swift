//
//  StateModelTests.swift
//  Meal PlannerTests
//
//  Created by Codex on 15/7/2026.
//

import Testing
@testable import Meal_Planner

struct StateModelTests {

    @Test func favouriteStateDerivesFiltersAndAvailableOptions() {
        var state = FavouriteState(items: [
            UIRecipeItem.new(id: "1", name: "A", area: "Thai", category: "Seafood"),
            UIRecipeItem.new(id: "2", name: "B", area: "Thai", category: "Dessert"),
            UIRecipeItem.new(id: "3", name: "C", area: "Canadian", category: "Seafood")
        ])

        #expect(state.availableAreas == ["Canadian", "Thai"])
        #expect(state.availableCategories == ["Dessert", "Seafood"])
        #expect(state.filteredItems.map(\.id) == ["1", "2", "3"])

        state.selectedArea = "Thai"
        state.selectedCategory = "Seafood"

        #expect(state.filteredItems.map(\.id) == ["1"])
    }

    @Test func authStateCanSubmitRequiresCredentialsAndIdleSubmitState() {
        #expect(AuthState().canSubmit == false)
        #expect(AuthState(email: "eric", password: "test").canSubmit)
        #expect(AuthState(email: "eric", password: "test", isLoggingIn: true).canSubmit == false)
    }

    @Test func detailStatePresentationFollowsSelectedItem() {
        #expect(DetailState().isPresented == false)
        #expect(DetailState(item: UIRecipeItem.new(id: "1", name: "Recipe")).isPresented)
    }

    @Test func loadPhaseEqualityIncludesErrorMessage() {
        #expect(LoadPhase.error("Search failed.") == .error("Search failed."))
        #expect(LoadPhase.error("Search failed.") != .error("Failed to load favourites."))
    }
}

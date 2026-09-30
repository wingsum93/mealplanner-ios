//
//  StateModelTests.swift
//  Meal PlannerTests
//
//  Created by Codex on 15/7/2026.
//

import Testing
import Foundation
@testable import Meal_Planner

struct StateModelTests {

    @Test func myListStateDerivesFiltersAndAvailableOptions() {
        var state = MyListState(items: [
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

    @Test func uiRecipeItemPrecomputesDisplayTags() {
        let item = UIRecipeItem(
            id: "1",
            name: "Recipe",
            description: "",
            area: nil,
            category: nil,
            thumbURL: nil,
            ingredients: ["long ingredient", "egg", "rice"],
            measures: [],
            instructions: [],
            tags: [],
            youtubeLink: ""
        )

        #expect(item.displayTags == ["egg", "rice", "long ingredient"])
    }

    @Test func planStateCachesDerivedScheduleMealsAndIngredients() {
        var state = PlanState()
        let calendar = Calendar.current
        let firstDay = calendar.startOfDay(for: Date(timeIntervalSince1970: 0))
        let secondDay = calendar.date(byAdding: .day, value: 1, to: firstDay)!

        state.favourites = [
            UIRecipeItem.new(id: "2", name: "Second"),
            UIRecipeItem.new(id: "1", name: "First")
        ]
        state.randomPool = [UIRecipeItem.new(id: "3", name: "Third")]
        #expect(state.mealsById[1]?.name == "First")
        #expect(state.mealsById[3]?.name == "Third")

        state.selectedMealIds = [3, 1]
        #expect(state.selectedMealIdsSorted == [1, 3])

        state.schedule = [
            PlanSlot(date: secondDay, timebox: .dinner, mealId: 2, displayOrder: 1),
            PlanSlot(date: firstDay, timebox: .lunch, mealId: 1, displayOrder: 0),
            PlanSlot(date: secondDay, timebox: .lunch, mealId: 3, displayOrder: 0)
        ]
        #expect(state.mealSlotsByDay.map(\.date) == [firstDay, secondDay])
        #expect(state.mealSlotsByDay[1].slots.map(\.mealId) == [3, 2])

        state.ingredients = [
            PlanIngredient(name: "Beef", quantityText: "200 g", unit: "g", category: .meat, isChecked: true, occurrenceCount: 1),
            PlanIngredient(name: "Basil", quantityText: "1 bunch", unit: "bunch", category: .herbs, occurrenceCount: 2)
        ]
        #expect(state.checkedIngredientCount == 1)
        #expect(state.ingredientGroups.map(\.category) == [.meat, .herbs])

        state.ingredients[1].isChecked = true
        state.refreshIngredientDerivedData()
        #expect(state.checkedIngredientCount == 2)
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

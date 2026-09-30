//
//  IngredientAggregatorTests.swift
//  Meal PlannerTests
//

import Testing
import Foundation

struct IngredientAggregatorTests {
    private func recipe(id: Int64, ingredients: [String], measures: [String]) -> RecipeItem {
        RecipeItem(
            id: id,
            title: "Recipe \(id)",
            description: "",
            category: "",
            area: "",
            imageUrl: "",
            youtubeLink: "",
            ingredients: ingredients,
            measures: measures,
            instructions: [],
            tags: [],
            isFavorite: false
        )
    }

    @Test func sumsQuantitiesForSameIngredientAndUnit() {
        let aggregator = IngredientAggregator()
        let item = recipe(id: 1, ingredients: ["Chicken", "Salt"], measures: ["200g", "1 tsp"])

        let result = aggregator.aggregate(meals: [(item, 2)])

        let chicken = result.first { $0.name == "Chicken" }
        #expect(chicken?.quantityText == "400 g")
        #expect(chicken?.occurrenceCount == 2)
        #expect(chicken?.category == .meat)
    }

    @Test func differentUnitsAreListedSeparately() {
        let aggregator = IngredientAggregator()
        let grams = recipe(id: 1, ingredients: ["Sugar"], measures: ["100g"])
        let cups = recipe(id: 2, ingredients: ["Sugar"], measures: ["2 cups"])

        let result = aggregator.aggregate(meals: [(grams, 1), (cups, 1)])

        #expect(result.filter { $0.name == "Sugar" }.count == 2)
    }

    @Test func deDuplicatesSameIngredientAcrossMeals() {
        let aggregator = IngredientAggregator()
        let first = recipe(id: 1, ingredients: ["Onion"], measures: ["1"])
        let second = recipe(id: 2, ingredients: ["Onion"], measures: ["2"])

        let result = aggregator.aggregate(meals: [(first, 1), (second, 1)])

        #expect(result.filter { $0.name == "Onion" }.count == 1)
        #expect(result.first { $0.name == "Onion" }?.quantityText == "3")
    }

    @Test func categorizerAssignsCategories() {
        let categorizer = IngredientCategorizer()
        #expect(categorizer.category(for: "Salmon fillet") == .seafood)
        #expect(categorizer.category(for: "Chicken breast") == .meat)
        #expect(categorizer.category(for: "Fresh basil") == .herbs)
        #expect(categorizer.category(for: "Red onion") == .vegetable)
        #expect(categorizer.category(for: "Water") == .others)
    }

    @Test func parserHandlesMixedFractionsAndUnits() {
        let parsed = QuantityParser.parse("1 1/2 cups")
        #expect(parsed.value == 1.5)
        #expect(parsed.unit == "cup")
    }

    @Test func unparsableMeasureKeepsOriginalText() {
        let aggregator = IngredientAggregator()
        let item = recipe(id: 1, ingredients: ["Salt"], measures: ["to taste"])

        let result = aggregator.aggregate(meals: [(item, 1)])

        #expect(result.first?.quantityText == "to taste")
    }
}
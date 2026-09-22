//
//  PlanModels.swift
//  Meal Planner
//
//  Domain models for the meal-planning / procurement feature (FX-001).
//

import Foundation

/// A meal timebox within a planned day. Breakfast is out of scope in v1.
enum PlanTimebox: String, CaseIterable, Identifiable, Codable, Hashable {
    case lunch
    case dinner

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        }
    }

    var systemImage: String {
        switch self {
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        }
    }
}

/// The five canonical procurement categories (FX-001 §5.5 / Q2).
enum IngredientCategory: Int, CaseIterable, Identifiable, Codable {
    case meat = 0
    case seafood = 1
    case vegetable = 2
    case herbs = 3
    case others = 4

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .meat: return "Meat"
        case .seafood: return "Seafood"
        case .vegetable: return "Vegetable"
        case .herbs: return "Herbs"
        case .others: return "Others"
        }
    }

    var systemImage: String {
        switch self {
        case .meat: return "flame"
        case .seafood: return "fish"
        case .vegetable: return "leaf"
        case .herbs: return "laurel.leading"
        case .others: return "shippingbox"
        }
    }
}

/// Tab source for the Step 2 meal picker.
enum PlanSourceTab: String, CaseIterable, Identifiable {
    case favourites
    case mastered
    case recent
    case random

    var id: String { rawValue }

    var title: String {
        switch self {
        case .favourites: return "Favorites"
        case .mastered: return "Mastered"
        case .recent: return "Recently viewed"
        case .random: return "Random (10)"
        }
    }
}

struct PlanSlot: Identifiable, Equatable, Hashable {
    let id: UUID
    var date: Date
    var timebox: PlanTimebox
    var mealId: Int64
    var displayOrder: Int

    init(
        id: UUID = UUID(),
        date: Date,
        timebox: PlanTimebox,
        mealId: Int64,
        displayOrder: Int
    ) {
        self.id = id
        self.date = date
        self.timebox = timebox
        self.mealId = mealId
        self.displayOrder = displayOrder
    }
}

struct PlanIngredient: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var quantityText: String
    var unit: String
    var category: IngredientCategory
    var isChecked: Bool
    var occurrenceCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        quantityText: String,
        unit: String,
        category: IngredientCategory,
        isChecked: Bool = false,
        occurrenceCount: Int
    ) {
        self.id = id
        self.name = name
        self.quantityText = quantityText
        self.unit = unit
        self.category = category
        self.isChecked = isChecked
        self.occurrenceCount = occurrenceCount
    }
}

struct ProcurementPlan: Identifiable, Equatable {
    let id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var createdAt: Date
    var adjustCount: Int
    var slots: [PlanSlot]
    var ingredients: [PlanIngredient]

    var dayCount: Int {
        SlotMath.dayCount(start: startDate, end: endDate)
    }

    var mealInstanceCount: Int {
        slots.count
    }

    var checkedIngredientCount: Int {
        ingredients.filter(\.isChecked).count
    }
}
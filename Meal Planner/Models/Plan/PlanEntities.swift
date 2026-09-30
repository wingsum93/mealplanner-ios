//
//  PlanEntities.swift
//  Meal Planner
//
//  SwiftData persistence for meal-planning / procurement plans (FX-001 §6).
//

import Foundation
import SwiftData

@Model
final class ProcurementPlanEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var createdAt: Date
    var adjustCount: Int
    var selectedTimeboxesRaw: String?
    var mealSnapshotsData: Data?

    @Relationship(deleteRule: .cascade, inverse: \PlanSlotEntity.plan)
    var slots: [PlanSlotEntity]

    @Relationship(deleteRule: .cascade, inverse: \PlanIngredientEntity.plan)
    var ingredients: [PlanIngredientEntity]

    init(
        id: UUID,
        name: String,
        startDate: Date,
        endDate: Date,
        createdAt: Date,
        adjustCount: Int,
        selectedTimeboxesRaw: String? = nil,
        mealSnapshotsData: Data? = nil,
        slots: [PlanSlotEntity] = [],
        ingredients: [PlanIngredientEntity] = []
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
        self.adjustCount = adjustCount
        self.selectedTimeboxesRaw = selectedTimeboxesRaw
        self.mealSnapshotsData = mealSnapshotsData
        self.slots = slots
        self.ingredients = ingredients
    }
}

@Model
final class PlanSlotEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var timeboxRaw: String
    var mealId: Int64
    var displayOrder: Int
    var plan: ProcurementPlanEntity?

    init(
        id: UUID,
        date: Date,
        timeboxRaw: String,
        mealId: Int64,
        displayOrder: Int
    ) {
        self.id = id
        self.date = date
        self.timeboxRaw = timeboxRaw
        self.mealId = mealId
        self.displayOrder = displayOrder
    }
}

@Model
final class PlanIngredientEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var quantityText: String
    var unit: String
    var categoryRaw: Int
    var checked: Bool
    var occurrenceCount: Int
    var plan: ProcurementPlanEntity?

    init(
        id: UUID,
        name: String,
        quantityText: String,
        unit: String,
        categoryRaw: Int,
        checked: Bool,
        occurrenceCount: Int
    ) {
        self.id = id
        self.name = name
        self.quantityText = quantityText
        self.unit = unit
        self.categoryRaw = categoryRaw
        self.checked = checked
        self.occurrenceCount = occurrenceCount
    }
}

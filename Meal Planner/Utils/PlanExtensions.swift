//
//  PlanExtensions.swift
//  Meal Planner
//
//  Entity ↔ domain mapping for procurement plans.
//

import Foundation

extension ProcurementPlanEntity {
    func toDomain() -> ProcurementPlan {
        ProcurementPlan(
            id: id,
            name: name,
            startDate: startDate,
            endDate: endDate,
            createdAt: createdAt,
            adjustCount: adjustCount,
            slots: slots
                .sorted { $0.displayOrder < $1.displayOrder }
                .map { $0.toDomain() },
            ingredients: ingredients.map { $0.toDomain() },
            selectedTimeboxes: Set((selectedTimeboxesRaw ?? "")
                .split(separator: ",")
                .compactMap { PlanTimebox(rawValue: String($0)) }),
            mealSnapshots: (mealSnapshotsData.flatMap {
                try? JSONDecoder().decode([PlanMealSnapshot].self, from: $0)
            }) ?? []
        )
    }
}

extension PlanSlotEntity {
    func toDomain() -> PlanSlot {
        PlanSlot(
            id: id,
            date: date,
            timebox: PlanTimebox(rawValue: timeboxRaw) ?? .lunch,
            mealId: mealId,
            displayOrder: displayOrder
        )
    }
}

extension PlanIngredientEntity {
    func toDomain() -> PlanIngredient {
        PlanIngredient(
            id: id,
            name: name,
            quantityText: quantityText,
            unit: unit,
            category: IngredientCategory(rawValue: categoryRaw) ?? .others,
            isChecked: checked,
            occurrenceCount: occurrenceCount
        )
    }
}

extension ProcurementPlan {
    func toEntity() -> ProcurementPlanEntity {
        ProcurementPlanEntity(
            id: id,
            name: name,
            startDate: startDate,
            endDate: endDate,
            createdAt: createdAt,
            adjustCount: adjustCount,
            selectedTimeboxesRaw: selectedTimeboxes.map(\.rawValue).sorted().joined(separator: ","),
            mealSnapshotsData: try? JSONEncoder().encode(mealSnapshots),
            slots: slots.map { $0.toEntity() },
            ingredients: ingredients.map { $0.toEntity() }
        )
    }
}

extension PlanSlot {
    func toEntity() -> PlanSlotEntity {
        PlanSlotEntity(
            id: id,
            date: date,
            timeboxRaw: timebox.rawValue,
            mealId: mealId,
            displayOrder: displayOrder
        )
    }
}

extension PlanIngredient {
    func toEntity() -> PlanIngredientEntity {
        PlanIngredientEntity(
            id: id,
            name: name,
            quantityText: quantityText,
            unit: unit,
            categoryRaw: category.rawValue,
            checked: isChecked,
            occurrenceCount: occurrenceCount
        )
    }
}

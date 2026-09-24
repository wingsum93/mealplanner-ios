//
//  PlanLocalDataSourceImpl.swift
//  Meal Planner
//

import Foundation
import SwiftData

public final class PlanLocalDataSourceImpl: PlanLocalDataSource {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func savePlan(_ plan: ProcurementPlanEntity) throws {
        context.insert(plan)
        let slots = plan.slots
        let ingredients = plan.ingredients
        for slot in slots {
            context.insert(slot)
            slot.plan = plan
        }
        for ingredient in ingredients {
            context.insert(ingredient)
            ingredient.plan = plan
        }
        do { try context.save() } catch { context.rollback(); throw error }
    }

    func getPlans() throws -> [ProcurementPlanEntity] {
        let descriptor = FetchDescriptor<ProcurementPlanEntity>(
            sortBy: [SortDescriptor(\ProcurementPlanEntity.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func getPlan(id: UUID) throws -> ProcurementPlanEntity? {
        let descriptor = FetchDescriptor<ProcurementPlanEntity>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    func deletePlan(id: UUID) throws {
        let descriptor = FetchDescriptor<ProcurementPlanEntity>(
            predicate: #Predicate { $0.id == id }
        )
        try context.fetch(descriptor).forEach { context.delete($0) }
        try context.save()
    }

    func setIngredientChecked(planId: UUID, ingredientId: UUID, isChecked: Bool) throws {
        guard let plan = try getPlan(id: planId),
              let ingredient = plan.ingredients.first(where: { $0.id == ingredientId }) else {
            throw CocoaError(.fileNoSuchFile)
        }
        ingredient.checked = isChecked
        do { try context.save() } catch { context.rollback(); throw error }
    }

    func updateSchedule(planId: UUID, slots: [PlanSlot]) throws {
        guard let plan = try getPlan(id: planId), plan.slots.count == slots.count else {
            throw CocoaError(.fileNoSuchFile)
        }
        let stored = Dictionary(uniqueKeysWithValues: plan.slots.map { ($0.id, $0) })
        guard slots.allSatisfy({ stored[$0.id] != nil }) else { throw CocoaError(.fileReadCorruptFile) }
        for slot in slots {
            guard let entity = stored[slot.id] else { continue }
            entity.date = slot.date
            entity.timeboxRaw = slot.timebox.rawValue
            entity.displayOrder = slot.displayOrder
        }
        do { try context.save() } catch { context.rollback(); throw error }
    }

    func updateSnapshots(planId: UUID, snapshots: [PlanMealSnapshot]) throws {
        guard let plan = try getPlan(id: planId) else { throw CocoaError(.fileNoSuchFile) }
        plan.mealSnapshotsData = try JSONEncoder().encode(snapshots)
        do { try context.save() } catch { context.rollback(); throw error }
    }
}

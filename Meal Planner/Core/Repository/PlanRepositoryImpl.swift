//
//  PlanRepositoryImpl.swift
//  Meal Planner
//

import Foundation

final class PlanRepositoryImpl: PlanRepository {
    private let local: PlanLocalDataSource

    init(local: PlanLocalDataSource) {
        self.local = local
    }

    func savePlan(_ plan: ProcurementPlan) throws {
        // Overwrite semantics: a plan with the same id replaces the stored one.
        try? local.deletePlan(id: plan.id)
        try local.savePlan(plan.toEntity())
    }

    func getPlans() throws -> [ProcurementPlan] {
        try local.getPlans().map { $0.toDomain() }
    }

    func getPlan(id: UUID) throws -> ProcurementPlan? {
        try local.getPlan(id: id)?.toDomain()
    }

    func deletePlan(id: UUID) throws {
        try local.deletePlan(id: id)
    }

    func setIngredientChecked(planId: UUID, ingredientId: UUID, isChecked: Bool) throws {
        try local.setIngredientChecked(planId: planId, ingredientId: ingredientId, isChecked: isChecked)
    }

    func updateSchedule(planId: UUID, slots: [PlanSlot]) throws {
        try local.updateSchedule(planId: planId, slots: slots)
    }

    func updateSnapshots(planId: UUID, snapshots: [PlanMealSnapshot]) throws {
        try local.updateSnapshots(planId: planId, snapshots: snapshots)
    }
}

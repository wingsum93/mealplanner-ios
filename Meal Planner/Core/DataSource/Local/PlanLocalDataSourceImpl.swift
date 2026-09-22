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
        try context.save()
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
        guard let plan = try getPlan(id: planId) else { return }
        if let ingredient = plan.ingredients.first(where: { $0.id == ingredientId }) {
            ingredient.checked = isChecked
            try context.save()
        }
    }
}
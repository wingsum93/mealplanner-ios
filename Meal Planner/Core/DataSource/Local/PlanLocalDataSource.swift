//
//  PlanLocalDataSource.swift
//  Meal Planner
//

import Foundation

protocol PlanLocalDataSource {
    func savePlan(_ plan: ProcurementPlanEntity) throws
    func getPlans() throws -> [ProcurementPlanEntity]
    func getPlan(id: UUID) throws -> ProcurementPlanEntity?
    func deletePlan(id: UUID) throws
    func setIngredientChecked(planId: UUID, ingredientId: UUID, isChecked: Bool) throws
}
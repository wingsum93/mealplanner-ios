//
//  PlanRepository.swift
//  Meal Planner
//

import Foundation

protocol PlanRepository {
    func savePlan(_ plan: ProcurementPlan) throws
    func getPlans() throws -> [ProcurementPlan]
    func getPlan(id: UUID) throws -> ProcurementPlan?
    func deletePlan(id: UUID) throws
    func setIngredientChecked(planId: UUID, ingredientId: UUID, isChecked: Bool) throws
}
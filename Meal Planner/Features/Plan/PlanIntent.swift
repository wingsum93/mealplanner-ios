//
//  PlanIntent.swift
//  Meal Planner
//

import Foundation

enum PlanIntent {
    // Saved plans
    case loadPlans
    case deletePlan(UUID)
    case copyPlan(UUID)
    case clearError
    case toggleSavedIngredient(planId: UUID, ingredientId: UUID, isChecked: Bool)

    // Wizard lifecycle
    case openWizard
    case closeWizard

    // Step 1 — period
    case setStartDate(Date)
    case setEndDate(Date)
    case toggleTimebox(PlanTimebox)

    // Step 2 — meals
    case selectTab(PlanSourceTab)
    case toggleMeal(Int64)
    case regenerateRandom

    // Navigation
    case nextStep
    case previousStep
    case goToStep(PlanWizardStep)

    // Step 3 — schedule
    case generateSchedule
    case shuffleSchedule
    case replaceSlot(slotId: UUID, mealId: Int64)
    case swapSlots(UUID, UUID)
    case clearDay(Date)

    // Step 4 — ingredients
    case toggleIngredient(UUID)
    case toggleCategory(IngredientCategory)

    // Step 5 — save
    case setPlanName(String)
    case savePlan
}
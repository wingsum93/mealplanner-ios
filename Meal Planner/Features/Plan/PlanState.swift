//
//  PlanState.swift
//  Meal Planner
//

import Foundation

enum PlanWizardStep: Int, CaseIterable, Identifiable {
    case period
    case meals
    case schedule
    case ingredients
    case save

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .period: return "Plan Period"
        case .meals: return "Pick Meals"
        case .schedule: return "Schedule"
        case .ingredients: return "Ingredients"
        case .save: return "Save Plan"
        }
    }

    var next: PlanWizardStep? { PlanWizardStep(rawValue: rawValue + 1) }
    var previous: PlanWizardStep? { PlanWizardStep(rawValue: rawValue - 1) }
}

struct PlanState: Equatable {
    // MARK: Saved plans
    var phase: LoadPhase = .idle
    var plans: [ProcurementPlan] = []
    var errorMessage: String?
    var undoPlanId: UUID?

    // MARK: Wizard
    var isWizardPresented = false
    var step: PlanWizardStep = .period
    var startDate: Date = Date()
    var endDate: Date = Calendar.current.date(byAdding: .day, value: 6, to: Date()) ?? Date()
    var timeboxes: Set<PlanTimebox> = [.lunch, .dinner]

    var selectedTab: PlanSourceTab = .favourites
    var favourites: [UIRecipeItem] = []
    var mastered: [UIRecipeItem] = []
    var recent: [UIRecipeItem] = []
    var randomPool: [UIRecipeItem] = []

    var selectedMealIds: Set<Int64> = []
    var schedule: [PlanSlot] = []
    var ingredients: [PlanIngredient] = []
    var planName: String = ""
    var adjustCount: Int = 0
    var isLoadingMeals = false
    var isLoadingRandom = false

    // MARK: Derived
    var dayDates: [Date] {
        SlotMath.dates(start: startDate, end: endDate)
    }

    var dayCount: Int {
        SlotMath.dayCount(start: startDate, end: endDate)
    }

    var slotCount: Int {
        SlotMath.totalSlots(dayCount: dayCount, timeboxes: timeboxes)
    }

    var slotCaption: String {
        SlotMath.caption(dayCount: dayCount, timeboxes: timeboxes)
    }

    var selectedMealCount: Int { selectedMealIds.count }

    var currentTabMeals: [UIRecipeItem] {
        switch selectedTab {
        case .favourites: return favourites
        case .mastered: return mastered
        case .recent: return recent
        case .random: return randomPool
        }
    }

    var mealSlotsByDay: [(date: Date, slots: [PlanSlot])] {
        let grouped = Dictionary(grouping: schedule, by: { Calendar.current.startOfDay(for: $0.date) })
        return grouped
            .map { (date: $0.key, slots: $0.value.sorted { $0.displayOrder < $1.displayOrder }) }
            .sorted { $0.date < $1.date }
    }

    var ingredientGroups: [(category: IngredientCategory, items: [PlanIngredient])] {
        IngredientCategory.allCases.compactMap { category in
            let items = ingredients.filter { $0.category == category }
            return items.isEmpty ? nil : (category, items)
        }
    }

    var checkedIngredientCount: Int {
        ingredients.filter(\.isChecked).count
    }

    func meal(id: Int64) -> UIRecipeItem? {
        let key = String(id)
        return (favourites + mastered + recent + randomPool).first { $0.id == key }
    }

    func isSelected(_ id: Int64) -> Bool {
        selectedMealIds.contains(id)
    }

    var canAdvance: Bool {
        switch step {
        case .period:
            return !timeboxes.isEmpty && dayCount >= SlotMath.minDays
        case .meals:
            return !selectedMealIds.isEmpty
        case .schedule:
            return !schedule.isEmpty
        case .ingredients, .save:
            return true
        }
    }
}

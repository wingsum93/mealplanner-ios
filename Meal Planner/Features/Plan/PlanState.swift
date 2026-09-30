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
    var favourites: [UIRecipeItem] = [] {
        didSet { refreshMealsById() }
    }
    var mastered: [UIRecipeItem] = [] {
        didSet { refreshMealsById() }
    }
    var recent: [UIRecipeItem] = [] {
        didSet { refreshMealsById() }
    }
    var randomPool: [UIRecipeItem] = [] {
        didSet { refreshMealsById() }
    }

    var selectedMealIds: Set<Int64> = [] {
        didSet { selectedMealIdsSorted = selectedMealIds.sorted() }
    }
    var schedule: [PlanSlot] = [] {
        didSet { refreshMealSlotsByDay() }
    }
    var ingredients: [PlanIngredient] = [] {
        didSet { refreshIngredientDerivedData() }
    }
    var planName: String = ""
    var adjustCount: Int = 0
    var isLoadingMeals = false
    var isLoadingRandom = false
    private(set) var selectedMealIdsSorted: [Int64] = []
    private(set) var mealSlotsByDay: [(date: Date, slots: [PlanSlot])] = []
    private(set) var ingredientGroups: [(category: IngredientCategory, items: [PlanIngredient])] = []
    private(set) var checkedIngredientCount: Int = 0
    private(set) var mealsById: [Int64: UIRecipeItem] = [:]

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

    mutating func refreshMealSlotsByDay() {
        let grouped = Dictionary(grouping: schedule, by: { Calendar.current.startOfDay(for: $0.date) })
        mealSlotsByDay = grouped
            .map { (date: $0.key, slots: $0.value.sorted { $0.displayOrder < $1.displayOrder }) }
            .sorted { $0.date < $1.date }
    }

    mutating func refreshIngredientDerivedData() {
        let grouped = Dictionary(grouping: ingredients, by: \.category)
        ingredientGroups = IngredientCategory.allCases.compactMap { category in
            let items = grouped[category] ?? []
            return items.isEmpty ? nil : (category, items)
        }
        checkedIngredientCount = ingredients.reduce(into: 0) { count, ingredient in
            if ingredient.isChecked {
                count += 1
            }
        }
    }

    mutating func refreshMealsById() {
        var lookup: [Int64: UIRecipeItem] = [:]
        for item in favourites + mastered + recent + randomPool {
            if let id = Int64(item.id) {
                lookup[id] = item
            }
        }
        mealsById = lookup
    }

    func meal(id: Int64) -> UIRecipeItem? {
        mealsById[id]
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

    static func == (lhs: PlanState, rhs: PlanState) -> Bool {
        lhs.phase == rhs.phase
            && lhs.plans == rhs.plans
            && lhs.errorMessage == rhs.errorMessage
            && lhs.undoPlanId == rhs.undoPlanId
            && lhs.isWizardPresented == rhs.isWizardPresented
            && lhs.step == rhs.step
            && lhs.startDate == rhs.startDate
            && lhs.endDate == rhs.endDate
            && lhs.timeboxes == rhs.timeboxes
            && lhs.selectedTab == rhs.selectedTab
            && lhs.favourites == rhs.favourites
            && lhs.mastered == rhs.mastered
            && lhs.recent == rhs.recent
            && lhs.randomPool == rhs.randomPool
            && lhs.selectedMealIds == rhs.selectedMealIds
            && lhs.schedule == rhs.schedule
            && lhs.ingredients == rhs.ingredients
            && lhs.planName == rhs.planName
            && lhs.adjustCount == rhs.adjustCount
            && lhs.isLoadingMeals == rhs.isLoadingMeals
            && lhs.isLoadingRandom == rhs.isLoadingRandom
    }
}

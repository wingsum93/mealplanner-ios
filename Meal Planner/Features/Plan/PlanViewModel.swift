//
//  PlanViewModel.swift
//  Meal Planner
//

import Foundation
import Combine

@MainActor
final class PlanViewModel: ObservableObject {
    @Published private(set) var state = PlanState()

    private let planRepository: PlanRepository
    private let recipeRepository: RecipeRepository
    private let aggregator = IngredientAggregator()
    private var scheduler: MealScheduler
    private var generator: any RandomNumberGenerator
    private var task: Task<Void, Never>?

    init(
        planRepository: PlanRepository,
        recipeRepository: RecipeRepository,
        generator: any RandomNumberGenerator = SystemRandomNumberGenerator()
    ) {
        self.planRepository = planRepository
        self.recipeRepository = recipeRepository
        self.generator = generator
        self.scheduler = MealScheduler(generator: generator)
    }

    deinit { task?.cancel() }

    func onIntent(_ intent: PlanIntent) {
        switch intent {
        case .loadPlans:
            loadPlans()
        case .deletePlan(let id):
            deletePlan(id)
        case .copyPlan(let id):
            copyPlan(id)
        case .clearError:
            state.errorMessage = nil
        case .toggleSavedIngredient(let planId, let ingredientId, let isChecked):
            toggleSavedIngredient(planId: planId, ingredientId: ingredientId, isChecked: isChecked)

        case .openWizard:
            openWizard()
        case .closeWizard:
            state.isWizardPresented = false

        case .setStartDate(let date):
            state.startDate = Calendar.current.startOfDay(for: date)
            state.endDate = SlotMath.clampedEnd(start: state.startDate, end: state.endDate)
        case .setEndDate(let date):
            state.endDate = SlotMath.clampedEnd(start: state.startDate, end: date)
        case .toggleTimebox(let timebox):
            if state.timeboxes.contains(timebox) {
                state.timeboxes.remove(timebox)
            } else {
                state.timeboxes.insert(timebox)
            }

        case .selectTab(let tab):
            state.selectedTab = tab
        case .toggleMeal(let id):
            if state.selectedMealIds.contains(id) {
                state.selectedMealIds.remove(id)
            } else {
                state.selectedMealIds.insert(id)
            }
        case .regenerateRandom:
            state.randomPool = Array(shuffled(uniqueMealPool()).prefix(10))

        case .nextStep:
            advance()
        case .previousStep:
            if let previous = state.step.previous { state.step = previous }
        case .goToStep(let step):
            state.step = step

        case .generateSchedule:
            generateSchedule()
        case .shuffleSchedule:
            state.schedule = scheduler.shuffle(slots: state.schedule, meals: Array(state.selectedMealIds))
            state.adjustCount += 1
        case .replaceSlot(let slotId, let mealId):
            if let index = state.schedule.firstIndex(where: { $0.id == slotId }) {
                state.schedule[index].mealId = mealId
                state.adjustCount += 1
            }
        case .swapSlots(let first, let second):
            swapSlots(first, second)
        case .clearDay(let date):
            let day = Calendar.current.startOfDay(for: date)
            state.schedule.removeAll { Calendar.current.startOfDay(for: $0.date) == day }
            state.adjustCount += 1

        case .toggleIngredient(let id):
            if let index = state.ingredients.firstIndex(where: { $0.id == id }) {
                state.ingredients[index].isChecked.toggle()
            }
        case .toggleCategory(let category):
            toggleCategory(category)

        case .setPlanName(let name):
            state.planName = name
        case .savePlan:
            savePlan()
        }
    }

    // MARK: - Saved plans

    func plan(id: UUID) -> ProcurementPlan? {
        state.plans.first { $0.id == id }
    }

    private func loadPlans() {
        task?.cancel()
        state.phase = .loading
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let plans = try planRepository.getPlans()
                guard !Task.isCancelled else { return }
                state.plans = plans
                state.phase = plans.isEmpty ? .empty : .content
            } catch {
                guard !Task.isCancelled else { return }
                state.plans = []
                state.phase = .error("Failed to load your meal plans.")
            }
            // Resolve meal titles for the detail views.
            await fetchMealSources()
        }
    }

    private func deletePlan(_ id: UUID) {
        do {
            try planRepository.deletePlan(id: id)
            state.plans.removeAll { $0.id == id }
            state.phase = state.plans.isEmpty ? .empty : .content
        } catch {
            state.errorMessage = "Failed to delete the plan. Please try again."
        }
    }

    private func copyPlan(_ id: UUID) {
        guard let original = plan(id: id) else { return }
        let copy = ProcurementPlan(
            id: UUID(),
            name: original.name + " (copy)",
            startDate: original.startDate,
            endDate: original.endDate,
            createdAt: Date(),
            adjustCount: original.adjustCount,
            slots: original.slots.map {
                PlanSlot(date: $0.date, timebox: $0.timebox, mealId: $0.mealId, displayOrder: $0.displayOrder)
            },
            ingredients: original.ingredients.map {
                PlanIngredient(
                    name: $0.name,
                    quantityText: $0.quantityText,
                    unit: $0.unit,
                    category: $0.category,
                    isChecked: false,
                    occurrenceCount: $0.occurrenceCount
                )
            }
        )
        do {
            try planRepository.savePlan(copy)
            state.plans.insert(copy, at: 0)
            state.phase = .content
        } catch {
            state.errorMessage = "Failed to copy the plan. Please try again."
        }
    }

    private func toggleSavedIngredient(planId: UUID, ingredientId: UUID, isChecked: Bool) {
        do {
            try planRepository.setIngredientChecked(
                planId: planId,
                ingredientId: ingredientId,
                isChecked: isChecked
            )
            if let planIndex = state.plans.firstIndex(where: { $0.id == planId }),
               let ingredientIndex = state.plans[planIndex].ingredients.firstIndex(where: { $0.id == ingredientId }) {
                state.plans[planIndex].ingredients[ingredientIndex].isChecked = isChecked
            }
        } catch {
            state.errorMessage = "Failed to update the list. Please try again."
        }
    }

    // MARK: - Wizard

    private func openWizard() {
        resetDraft()
        state.isWizardPresented = true
        state.step = .period
        task?.cancel()
        task = Task { [weak self] in
            await self?.fetchMealSources()
        }
    }

    private func resetDraft() {
        state.startDate = Calendar.current.startOfDay(for: Date())
        state.endDate = SlotMath.clampedEnd(start: state.startDate, end: Date())
        state.timeboxes = [.lunch, .dinner]
        state.selectedTab = .favourites
        state.selectedMealIds = []
        state.schedule = []
        state.ingredients = []
        state.planName = ""
        state.adjustCount = 0
    }

    private func fetchMealSources() async {
        state.isLoadingMeals = true
        // Offline-first: lists are loaded from the local repository.
        let favourites = (try? await recipeRepository.getRecipesInList(type: .favourite)) ?? []
        let mastered = (try? await recipeRepository.getRecipesInList(type: .mastered)) ?? []
        let recent = (try? await recipeRepository.getRecipesInList(type: .viewed)) ?? []
        guard !Task.isCancelled else { return }
        state.favourites = favourites.map { $0.toUI() }
        state.mastered = mastered.map { $0.toUI() }
        state.recent = recent.map { $0.toUI() }
        state.randomPool = Array(shuffled(uniqueMealPool()).prefix(10))
        state.isLoadingMeals = false
    }

    private func uniqueMealPool() -> [UIRecipeItem] {
        var seen = Set<String>()
        return (state.favourites + state.mastered + state.recent).filter {
            seen.insert($0.id).inserted
        }
    }

    private func advance() {
        guard state.canAdvance, let next = state.step.next else { return }
        switch (state.step, next) {
        case (.meals, .schedule):
            if Set(state.schedule.map(\.mealId)) != state.selectedMealIds {
                generateSchedule()
            }
        case (.schedule, .ingredients):
            recomputeIngredients()
        case (.ingredients, .save):
            if state.planName.trimmingCharacters(in: .whitespaces).isEmpty {
                state.planName = suggestedPlanName()
            }
        default:
            break
        }
        state.step = next
    }

    private func generateSchedule() {
        state.schedule = scheduler.allocate(
            meals: Array(state.selectedMealIds),
            dates: state.dayDates,
            timeboxes: MealScheduler.ordered(state.timeboxes)
        )
        state.adjustCount = 0
    }

    private func swapSlots(_ first: UUID, _ second: UUID) {
        guard let firstIndex = state.schedule.firstIndex(where: { $0.id == first }),
              let secondIndex = state.schedule.firstIndex(where: { $0.id == second }),
              firstIndex != secondIndex
        else { return }
        let mealId = state.schedule[firstIndex].mealId
        state.schedule[firstIndex].mealId = state.schedule[secondIndex].mealId
        state.schedule[secondIndex].mealId = mealId
        state.adjustCount += 1
    }

    private func recomputeIngredients() {
        let counts = Dictionary(grouping: state.schedule, by: \.mealId).mapValues(\.count)
        let meals: [(item: RecipeItem, occurrences: Int)] = counts.compactMap { mealId, occurrences in
            guard let ui = state.meal(id: mealId), let recipe = ui.toDomain() else { return nil }
            return (recipe, occurrences)
        }
        state.ingredients = aggregator.aggregate(meals: meals)
    }

    private func toggleCategory(_ category: IngredientCategory) {
        let indices = state.ingredients.indices.filter { state.ingredients[$0].category == category }
        guard !indices.isEmpty else { return }
        let allChecked = indices.allSatisfy { state.ingredients[$0].isChecked }
        for index in indices {
            state.ingredients[index].isChecked = !allChecked
        }
    }

    private func suggestedPlanName() -> String {
        let dates = state.dayDates
        guard let first = dates.first, let last = dates.last else { return "Meal Plan" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "Plan · \(formatter.string(from: first)) – \(formatter.string(from: last))"
    }

    private func savePlan() {
        let dates = state.dayDates
        let plan = ProcurementPlan(
            id: UUID(),
            name: state.planName.trimmingCharacters(in: .whitespaces).isEmpty
                ? suggestedPlanName()
                : state.planName,
            startDate: dates.first ?? state.startDate,
            endDate: dates.last ?? state.endDate,
            createdAt: Date(),
            adjustCount: state.adjustCount,
            slots: state.schedule,
            ingredients: state.ingredients
        )

        do {
            try planRepository.savePlan(plan)
            state.plans.insert(plan, at: 0)
            state.phase = .content
            state.isWizardPresented = false
        } catch {
            state.errorMessage = "Failed to save the plan. Please try again."
        }
    }

    private func shuffled<T>(_ items: [T]) -> [T] {
        var result = items
        guard result.count > 1 else { return result }
        for index in stride(from: result.count - 1, to: 0, by: -1) {
            let pick = Int(generator.next() % UInt64(index + 1))
            result.swapAt(index, pick)
        }
        return result
    }
}
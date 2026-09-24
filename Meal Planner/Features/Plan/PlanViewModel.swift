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
    private var task: Task<Void, Never>?
    private var randomTask: Task<Void, Never>?
    private var undoTask: Task<Void, Never>?
    private var undoSnapshot: ProcurementPlan?
    private var undoExpiresAt: Date?
    private let now: () -> Date

    init(
        planRepository: PlanRepository,
        recipeRepository: RecipeRepository,
        generator: any RandomNumberGenerator = SystemRandomNumberGenerator(),
        now: @escaping () -> Date = Date.init
    ) {
        self.planRepository = planRepository
        self.recipeRepository = recipeRepository
        self.scheduler = MealScheduler(generator: generator)
        self.now = now
    }

    deinit {
        task?.cancel()
        randomTask?.cancel()
        undoTask?.cancel()
    }

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
        case .moveSavedMeal(let planId, let sourceId, let date, let timebox):
            moveSavedMeal(planId: planId, sourceId: sourceId, date: date, timebox: timebox)
        case .undoSavedReorder(let id):
            undoSavedReorder(id)

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
            if tab == .random, state.randomPool.isEmpty {
                loadRandomMeals()
            }
        case .toggleMeal(let id):
            if state.selectedMealIds.contains(id) {
                state.selectedMealIds.remove(id)
            } else {
                state.selectedMealIds.insert(id)
            }
        case .regenerateRandom:
            loadRandomMeals()

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
                state.plans = plans.map { self.backfilled($0) }
                state.phase = plans.isEmpty ? .empty : .content
            } catch {
                guard !Task.isCancelled else { return }
                state.plans = []
                state.phase = .error("Failed to load your meal plans.")
            }
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
            },
            selectedTimeboxes: original.selectedTimeboxes,
            mealSnapshots: original.mealSnapshots
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

    private func backfilled(_ plan: ProcurementPlan) -> ProcurementPlan {
        var updated = plan
        let missingIds = Set(plan.slots.map(\.mealId)).subtracting(plan.mealSnapshots.map(\.id))
        for id in missingIds {
            if let recipe = try? recipeRepository.getCachedRecipe(id: id) {
                updated.mealSnapshots.append(PlanMealSnapshot(recipe: recipe))
            }
        }
        if updated.mealSnapshots != plan.mealSnapshots {
            try? planRepository.updateSnapshots(planId: plan.id, snapshots: updated.mealSnapshots)
        }
        return updated
    }

    private func moveSavedMeal(planId: UUID, sourceId: UUID, date: Date, timebox: PlanTimebox) {
        guard let original = plan(id: planId),
              let changed = PlanScheduleMutation.move(
                sourceId: sourceId, to: date, timebox: timebox, in: original, now: now()
              ) else { return }
        do {
            try planRepository.updateSchedule(planId: planId, slots: changed.slots)
            guard let index = state.plans.firstIndex(where: { $0.id == planId }) else { return }
            state.plans[index] = changed
            undoSnapshot = original
            undoExpiresAt = now().addingTimeInterval(5)
            state.undoPlanId = planId
            undoTask?.cancel()
            undoTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(5))
                guard !Task.isCancelled else { return }
                self?.clearUndo()
            }
        } catch {
            state.errorMessage = "Failed to move the meal. Please try again."
        }
    }

    private func undoSavedReorder(_ planId: UUID) {
        guard state.undoPlanId == planId, let previous = undoSnapshot,
              previous.id == planId, let expiry = undoExpiresAt, now() < expiry else {
            clearUndo()
            return
        }
        do {
            try planRepository.updateSchedule(planId: planId, slots: previous.slots)
            if let index = state.plans.firstIndex(where: { $0.id == planId }) {
                state.plans[index] = previous
            }
            clearUndo()
        } catch {
            state.errorMessage = "Failed to undo the move. Please try again."
        }
    }

    private func clearUndo() {
        undoTask?.cancel()
        undoTask = nil
        undoSnapshot = nil
        undoExpiresAt = nil
        state.undoPlanId = nil
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
        state.randomPool = []
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
        state.isLoadingMeals = false
    }

    private func loadRandomMeals() {
        randomTask?.cancel()
        state.isLoadingRandom = true
        randomTask = Task { [weak self] in
            guard let self else { return }
            let meals = (try? await recipeRepository.getRandom10Recipe())?
                .map { $0.toUI() }
                .dedupedByID() ?? []
            guard !Task.isCancelled else { return }
            if !meals.isEmpty {
                state.randomPool = meals
            }
            state.isLoadingRandom = false
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
            ingredients: state.ingredients,
            selectedTimeboxes: state.timeboxes,
            mealSnapshots: Set(state.schedule.map(\.mealId)).compactMap { id in
                state.meal(id: id)?.toDomain().map(PlanMealSnapshot.init(recipe:))
            }
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
}

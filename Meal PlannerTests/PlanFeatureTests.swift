import Testing
import Foundation
import SwiftData
@testable import Meal_Planner

struct PlanFeatureTests {
    private let calendar: Calendar = {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(identifier: "UTC")!
        return value
    }()

    private func date(_ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: day))!
    }

    private func plan() -> ProcurementPlan {
        ProcurementPlan(id: UUID(), name: "Week", startDate: date(20), endDate: date(26),
                        createdAt: date(20), adjustCount: 0,
                        slots: [PlanSlot(date: date(24), timebox: .lunch, mealId: 1, displayOrder: 0),
                                PlanSlot(date: date(25), timebox: .dinner, mealId: 2, displayOrder: 1)],
                        ingredients: [], selectedTimeboxes: [.lunch, .dinner])
    }

    @Test func calendarAndDestinationsRespectMealDaysAndTimeboxes() {
        let plan = plan()
        let source = plan.slots[0]
        let available = PlanScheduleMutation.validDestinations(for: source.id, in: plan, now: date(24), calendar: calendar)
        #expect(PlanScheduleMutation.hasMeals(on: date(23), in: plan, calendar: calendar) == false)
        #expect(PlanScheduleMutation.hasMeals(on: date(24), in: plan, calendar: calendar))
        #expect(available.count == 3)
        #expect(available.contains { calendar.isDate($0.date, inSameDayAs: date(25)) && $0.timebox == .lunch && !$0.occupied })
        #expect(available.contains { calendar.isDate($0.date, inSameDayAs: date(25)) && $0.timebox == .dinner && $0.occupied })
        #expect(PlanScheduleMutation.move(sourceId: source.id, to: date(26), timebox: .lunch,
                                          in: plan, now: date(24), calendar: calendar) == nil)
        #expect(PlanScheduleMutation.validDestinations(for: source.id, in: plan, now: date(25), calendar: calendar).isEmpty)
    }

    @Test func moveAndSwapKeepMealIdentityAndSnapshots() throws {
        var plan = plan()
        plan.mealSnapshots = [PlanMealSnapshot(recipe: makeRecipe(id: 1, title: "One"))]
        let source = plan.slots[0]
        let moved = try #require(PlanScheduleMutation.move(sourceId: source.id, to: date(25), timebox: .lunch,
                                                           in: plan, now: date(24), calendar: calendar))
        #expect(moved.slots[0].id == source.id && moved.slots[0].mealId == 1)
        #expect(moved.snapshot(for: 1) == plan.snapshot(for: 1))
        #expect(!PlanScheduleMutation.hasMeals(on: date(24), in: moved, calendar: calendar))
        let swapped = try #require(PlanScheduleMutation.move(sourceId: source.id, to: date(25), timebox: .dinner,
                                                             in: plan, now: date(24), calendar: calendar))
        #expect(swapped.slots[0].mealId == 1 && swapped.slots[1].mealId == 2)
        #expect(calendar.isDate(swapped.slots[1].date, inSameDayAs: date(24)))
        #expect(swapped.slots[1].timebox == .lunch)
    }

    @Test @MainActor func legacyPlanInfersTimeboxesAndAcceptsMissingSnapshots() throws {
        let container = try ModelContainer(for: ProcurementPlanEntity.self, PlanSlotEntity.self, PlanIngredientEntity.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let old = ProcurementPlanEntity(id: UUID(), name: "Old", startDate: date(20), endDate: date(26),
                                        createdAt: date(20), adjustCount: 0,
                                        slots: [PlanSlotEntity(id: UUID(), date: date(24), timeboxRaw: "dinner",
                                                               mealId: 8, displayOrder: 0)])
        container.mainContext.insert(old)
        try container.mainContext.save()
        let plan = old.toDomain()
        #expect(plan.availableTimeboxes == [.dinner])
        #expect(plan.snapshot(for: 8) == nil)
    }

    @Test @MainActor func repositoryRoundTripsSlotsIngredientsAndSnapshots() throws {
        let container = try ModelContainer(for: ProcurementPlanEntity.self, PlanSlotEntity.self, PlanIngredientEntity.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let repository = PlanRepositoryImpl(local: PlanLocalDataSourceImpl(context: ModelContext(container)))
        var fixture = plan()
        fixture.ingredients = [PlanIngredient(name: "Beef", quantityText: "200 g", unit: "g",
                                              category: .meat, occurrenceCount: 1)]
        fixture.mealSnapshots = [PlanMealSnapshot(id: 1, title: "Beef Bowl", ingredients: [])]
        try repository.savePlan(fixture)
        let saved = try repository.getPlan(id: fixture.id)
        let loaded = try #require(saved)
        #expect(loaded.slots.count == 2)
        #expect(loaded.ingredients.map(\.name) == ["Beef"])
        #expect(loaded.snapshot(for: 1)?.title == "Beef Bowl")
        let listed = try repository.getPlans()
        #expect(listed.first?.ingredients.map(\.name) == ["Beef"])
        try repository.setIngredientChecked(planId: fixture.id, ingredientId: fixture.ingredients[0].id, isChecked: true)
        let checked = try repository.getPlan(id: fixture.id)
        #expect(checked?.ingredients.first?.isChecked == true)
    }

    @Test @MainActor func persistenceFailureAndUndoWindow() async throws {
        let now = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        let original = ProcurementPlan(id: UUID(), name: "Week", startDate: now, endDate: tomorrow,
                                       createdAt: now, adjustCount: 0,
                                       slots: [PlanSlot(date: now, timebox: .lunch, mealId: 1, displayOrder: 0),
                                               PlanSlot(date: tomorrow, timebox: .dinner, mealId: 2, displayOrder: 1)],
                                       ingredients: [], selectedTimeboxes: [.lunch, .dinner])
        let repository = PlanFeatureRepository(plan: original)
        let recipes = DummyRecipeRepository()
        let clock = PlanTestClock(date: now)
        let vm = PlanViewModel(planRepository: repository, recipeRepository: recipes, now: { clock.date })
        vm.onIntent(.loadPlans)
        try await waitUntil { vm.state.phase == .content }

        repository.failScheduleSave = true
        vm.onIntent(.moveSavedMeal(planId: original.id, sourceId: original.slots[0].id,
                                   date: tomorrow, timebox: .lunch))
        #expect(vm.plan(id: original.id)?.slots == original.slots)
        #expect(vm.state.undoPlanId == nil)
        repository.failScheduleSave = false
        vm.onIntent(.moveSavedMeal(planId: original.id, sourceId: original.slots[0].id,
                                   date: tomorrow, timebox: .lunch))
        #expect(vm.state.undoPlanId == original.id)
        vm.onIntent(.undoSavedReorder(original.id))
        #expect(vm.plan(id: original.id)?.slots == original.slots)

        vm.onIntent(.moveSavedMeal(planId: original.id, sourceId: original.slots[0].id,
                                   date: tomorrow, timebox: .lunch))
        clock.date = now.addingTimeInterval(6)
        vm.onIntent(.undoSavedReorder(original.id))
        #expect(vm.plan(id: original.id)?.slots != original.slots)
    }

    @Test @MainActor func legacyBackfillUsesOnlyCachedRecipe() async throws {
        var old = plan()
        old.selectedTimeboxes = []
        let repository = PlanFeatureRepository(plan: old)
        let recipes = DummyRecipeRepository()
        recipes.cachedRecipes[1] = makeRecipe(id: 1, title: "Cached")
        let vm = PlanViewModel(planRepository: repository, recipeRepository: recipes)
        vm.onIntent(.loadPlans)
        try await waitUntil { vm.state.phase == .content }
        #expect(vm.plan(id: old.id)?.snapshot(for: 1)?.title == "Cached")
        #expect(vm.plan(id: old.id)?.snapshot(for: 2) == nil)
        #expect(repository.plan.mealSnapshots.count == 1)
    }
}

private final class PlanTestClock {
    var date: Date
    init(date: Date) { self.date = date }
}

private final class PlanFeatureRepository: PlanRepository {
    var plan: ProcurementPlan
    var failScheduleSave = false
    init(plan: ProcurementPlan) { self.plan = plan }
    func savePlan(_ plan: ProcurementPlan) throws { self.plan = plan }
    func getPlans() throws -> [ProcurementPlan] { [plan] }
    func getPlan(id: UUID) throws -> ProcurementPlan? { plan.id == id ? plan : nil }
    func deletePlan(id: UUID) throws {}
    func setIngredientChecked(planId: UUID, ingredientId: UUID, isChecked: Bool) throws {}
    func updateSchedule(planId: UUID, slots: [PlanSlot]) throws {
        if failScheduleSave { throw CocoaError(.fileWriteUnknown) }
        plan.slots = slots
    }
    func updateSnapshots(planId: UUID, snapshots: [PlanMealSnapshot]) throws { plan.mealSnapshots = snapshots }
}

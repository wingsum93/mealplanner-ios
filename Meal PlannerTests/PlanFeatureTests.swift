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

    @Test func calendarSnapshotMarksOnlyPlannedMealDaysEnabled() throws {
        let snapshot = PlanCalendarSnapshot(plan: plan(), month: date(24), calendar: calendar)
        let day23 = try #require(snapshot.days.first { $0.dayNumber == 23 })
        let day24 = try #require(snapshot.days.first { $0.dayNumber == 24 })
        let day25 = try #require(snapshot.days.first { $0.dayNumber == 25 })

        #expect(day23.isEnabled == false)
        #expect(day23.timeboxes.isEmpty)
        #expect(day24.isEnabled)
        #expect(day24.timeboxes == [.lunch])
        #expect(day25.isEnabled)
        #expect(day25.timeboxes == [.dinner])
        let monthStart = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 1)))
        #expect(snapshot.firstMonth == monthStart)
        #expect(snapshot.lastMonth == monthStart)
    }

    @Test func dayDetailSnapshotMatchesMoveDestinations() throws {
        let plan = plan()
        let source = plan.slots[0]
        let snapshot = PlanDayDetailSnapshot(plan: plan, displayedDate: date(24), now: date(24), calendar: calendar)
        let expected = PlanScheduleMutation.validDestinations(for: source.id, in: plan, now: date(24), calendar: calendar)

        #expect(snapshot.slots.map(\.slot.id) == [source.id])
        #expect(snapshot.availableTimeboxes == [.lunch, .dinner])
        for destination in expected {
            #expect(snapshot.hasValidDestination(
                for: source.id,
                date: destination.date,
                timebox: destination.timebox,
                calendar: calendar
            ))
        }
        #expect(snapshot.hasValidDestinationDate(for: source.id, date: date(25), calendar: calendar))
        #expect(snapshot.hasValidDestination(for: source.id, date: date(26), timebox: .lunch, calendar: calendar) == false)
    }

    @Test func ingredientCategorySnapshotSortsAndCountsPerCategory() {
        var fixture = plan()
        fixture.ingredients = [
            PlanIngredient(name: "Pork", quantityText: "100 g", unit: "g", category: .meat, isChecked: true, occurrenceCount: 1),
            PlanIngredient(name: "Apple", quantityText: "2", unit: "", category: .others, occurrenceCount: 1),
            PlanIngredient(name: "Beef", quantityText: "200 g", unit: "g", category: .meat, occurrenceCount: 2)
        ]

        let snapshot = PlanIngredientCategorySnapshot(plan: fixture)

        #expect(snapshot.items(for: .meat).map(\.name) == ["Beef", "Pork"])
        #expect(snapshot.totalCount(for: .meat) == 2)
        #expect(snapshot.checkedCount(for: .meat) == 1)
        #expect(snapshot.items(for: .vegetable).isEmpty)
        #expect(snapshot.checkedCount(for: .vegetable) == 0)
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

    @Test @MainActor func wizardDerivedStateRefreshesAfterScheduleAndIngredientIntents() async throws {
        let first = RecipeItem(
            id: 1,
            title: "Beef Bowl",
            description: "",
            category: "Main",
            area: "JP",
            imageUrl: "",
            youtubeLink: "",
            ingredients: ["Beef", "Rice"],
            measures: ["200 g", "1 cup"],
            instructions: [],
            tags: [],
            isFavorite: true
        )
        let second = RecipeItem(
            id: 2,
            title: "Chicken Bowl",
            description: "",
            category: "Main",
            area: "JP",
            imageUrl: "",
            youtubeLink: "",
            ingredients: ["Chicken"],
            measures: ["150 g"],
            instructions: [],
            tags: [],
            isFavorite: true
        )
        let recipeRepository = FavoriteRecipeRepository(favorites: [first, second])
        let vm = PlanViewModel(planRepository: PlanFeatureRepository(plan: plan()), recipeRepository: recipeRepository)

        vm.onIntent(.openWizard)
        try await waitUntil {
            !vm.state.isLoadingMeals && vm.state.favourites.map(\.id) == ["1", "2"]
        }
        vm.onIntent(.setStartDate(date(24)))
        vm.onIntent(.setEndDate(date(24)))
        vm.onIntent(.toggleMeal(1))
        vm.onIntent(.toggleMeal(2))
        #expect(vm.state.selectedMealIdsSorted == [1, 2])
        #expect(vm.state.mealsById[1]?.name == "Beef Bowl")

        vm.onIntent(.generateSchedule)
        #expect(vm.state.mealSlotsByDay.count == SlotMath.minDays)
        #expect(vm.state.schedule.count == SlotMath.minDays * 2)

        let firstSlot = try #require(vm.state.schedule.first)
        vm.onIntent(.replaceSlot(slotId: firstSlot.id, mealId: 2))
        let replacedSlotIsCached = vm.state.mealSlotsByDay
            .flatMap(\.slots)
            .contains { $0.id == firstSlot.id && $0.mealId == 2 }
        #expect(replacedSlotIsCached)

        vm.onIntent(.goToStep(.schedule))
        vm.onIntent(.nextStep)
        #expect(vm.state.ingredientGroups.isEmpty == false)
        #expect(vm.state.checkedIngredientCount == 0)

        let firstIngredient = try #require(vm.state.ingredients.first)
        vm.onIntent(.toggleIngredient(firstIngredient.id))
        #expect(vm.state.checkedIngredientCount == 1)

        vm.onIntent(.clearDay(date(24)))
        #expect(vm.state.mealSlotsByDay.count == SlotMath.minDays - 1)
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

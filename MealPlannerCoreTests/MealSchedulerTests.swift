//
//  MealSchedulerTests.swift
//  Meal PlannerTests
//

import Testing
import Foundation

struct MealSchedulerTests {
    private func dates(_ count: Int) -> [Date] {
        let base = Date(timeIntervalSince1970: 0)
        return (0..<count).map { base.addingTimeInterval(Double($0) * 86_400) }
    }

    @Test func allocationFillsEverySlot() {
        var scheduler = MealScheduler(generator: SeededRandomNumberGenerator(seed: 42))
        let slots = scheduler.allocate(meals: [1, 2, 3], dates: dates(3), timeboxes: [.lunch, .dinner])
        #expect(slots.count == 6)
    }

    @Test func allocationIsDeterministicForSeed() {
        var first = MealScheduler(generator: SeededRandomNumberGenerator(seed: 7))
        var second = MealScheduler(generator: SeededRandomNumberGenerator(seed: 7))
        let a = first.allocate(meals: [1, 2, 3, 4], dates: dates(4), timeboxes: [.lunch, .dinner])
        let b = second.allocate(meals: [1, 2, 3, 4], dates: dates(4), timeboxes: [.lunch, .dinner])
        #expect(a.map(\.mealId) == b.map(\.mealId))
    }

    @Test func noMealsProducesNoSlots() {
        var scheduler = MealScheduler(generator: SeededRandomNumberGenerator(seed: 1))
        #expect(scheduler.allocate(meals: [], dates: dates(3), timeboxes: [.lunch]).isEmpty)
    }

    @Test func repeatsWhenFewerMealsThanSlots() {
        var scheduler = MealScheduler(generator: SeededRandomNumberGenerator(seed: 3))
        let slots = scheduler.allocate(meals: [9], dates: dates(3), timeboxes: [.lunch, .dinner])
        #expect(slots.count == 6)
        #expect(slots.allSatisfy { $0.mealId == 9 })
    }

    @Test func avoidsSameMealInBothSlotsOfADayWhenPossible() {
        var scheduler = MealScheduler(generator: SeededRandomNumberGenerator(seed: 5))
        let slots = scheduler.allocate(meals: [1, 2], dates: dates(5), timeboxes: [.lunch, .dinner])
        let byDay = Dictionary(grouping: slots, by: { $0.date })
        #expect(byDay.count == 5)
        for (_, daySlots) in byDay {
            #expect(Set(daySlots.map(\.mealId)).count == 2)
        }
    }

    @Test func exceedMealsAreUnused() {
        var scheduler = MealScheduler(generator: SeededRandomNumberGenerator(seed: 11))
        let slots = scheduler.allocate(meals: [1, 2, 3, 4, 5], dates: dates(1), timeboxes: [.lunch, .dinner])
        #expect(slots.count == 2)
    }
}
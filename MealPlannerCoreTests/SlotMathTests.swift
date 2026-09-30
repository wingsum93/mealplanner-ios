//
//  SlotMathTests.swift
//  Meal PlannerTests
//

import Testing
import Foundation

struct SlotMathTests {
    private func calendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar().date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test func dayCountIsInclusive() {
        let cal = calendar()
        #expect(SlotMath.dayCount(start: date(2026, 7, 1), end: date(2026, 7, 7), calendar: cal) == 7)
        #expect(SlotMath.dayCount(start: date(2026, 7, 1), end: date(2026, 7, 1), calendar: cal) == 1)
    }

    @Test func clampedEndEnforcesMinimum() {
        let cal = calendar()
        let start = date(2026, 7, 1)
        let end = date(2026, 7, 3)
        let clamped = SlotMath.clampedEnd(start: start, end: end, calendar: cal)
        #expect(SlotMath.dayCount(start: start, end: clamped, calendar: cal) == SlotMath.minDays)
    }

    @Test func clampedEndEnforcesMaximum() {
        let cal = calendar()
        let start = date(2026, 7, 1)
        let end = date(2026, 9, 1)
        let clamped = SlotMath.clampedEnd(start: start, end: end, calendar: cal)
        #expect(SlotMath.dayCount(start: start, end: clamped, calendar: cal) == SlotMath.maxDays)
    }

    @Test func datesReturnsOneEntryPerDay() {
        let cal = calendar()
        let dates = SlotMath.dates(start: date(2026, 7, 1), end: date(2026, 7, 7), calendar: cal)
        #expect(dates.count == 7)
    }

    @Test func totalSlotsMultipliesByTimeboxes() {
        #expect(SlotMath.totalSlots(dayCount: 7, timeboxes: [.lunch, .dinner]) == 14)
        #expect(SlotMath.totalSlots(dayCount: 7, timeboxes: [.dinner]) == 7)
    }

    @Test func captionReflectsSlotsDaysAndMeals() {
        let caption = SlotMath.caption(dayCount: 7, timeboxes: [.lunch, .dinner])
        #expect(caption == "14 slots · 7 days × 2 meals")
    }
}
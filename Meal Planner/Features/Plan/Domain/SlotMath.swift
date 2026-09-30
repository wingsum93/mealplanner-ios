//
//  SlotMath.swift
//  Meal Planner
//
//  Pure slot/date math for the meal-planning wizard (FR-2.4, E8).
//

import Foundation

struct SlotMath {
    static let minDays = 7
    static let maxDays = 31

    /// Inclusive number of days between `start` and `end` (both start-of-day).
    static func dayCount(
        start: Date,
        end: Date,
        calendar: Calendar = .current
    ) -> Int {
        let startDay = calendar.startOfDay(for: start)
        let endDay = calendar.startOfDay(for: end)
        let delta = calendar.dateComponents([.day], from: startDay, to: endDay).day ?? 0
        return delta + 1
    }

    /// Clamps `end` so the range is never shorter than `minDays`.
    static func clampedEnd(
        start: Date,
        end: Date,
        calendar: Calendar = .current
    ) -> Date {
        let startDay = calendar.startOfDay(for: start)
        let count = dayCount(start: startDay, end: end, calendar: calendar)
        let clamped = min(max(count, minDays), maxDays)
        return calendar.date(byAdding: .day, value: clamped - 1, to: startDay) ?? startDay
    }

    /// Clamps `start` so the range is never longer than `maxDays` relative to `end`.
    static func clampedStart(
        start: Date,
        end: Date,
        calendar: Calendar = .current
    ) -> Date {
        let endDay = calendar.startOfDay(for: end)
        let count = dayCount(start: start, end: endDay, calendar: calendar)
        guard count > maxDays else { return start }
        return calendar.date(byAdding: .day, value: -(maxDays - 1), to: endDay) ?? start
    }

    /// Start-of-day dates for every day in the (clamped) range.
    static func dates(
        start: Date,
        end: Date,
        calendar: Calendar = .current
    ) -> [Date] {
        let startDay = calendar.startOfDay(for: start)
        let count = min(
            max(dayCount(start: start, end: end, calendar: calendar), minDays),
            maxDays
        )
        return (0..<count).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startDay)
        }
    }

    static func totalSlots(dayCount: Int, timeboxes: Set<PlanTimebox>) -> Int {
        max(dayCount, 0) * timeboxes.count
    }

    /// e.g. "14 slots · 7 days × 2 meals"
    static func caption(dayCount: Int, timeboxes: Set<PlanTimebox>) -> String {
        let slots = totalSlots(dayCount: dayCount, timeboxes: timeboxes)
        let mealWord = timeboxes.count == 1 ? "meal" : "meals"
        let dayWord = dayCount == 1 ? "day" : "days"
        return "\(slots) slots · \(dayCount) \(dayWord) × \(timeboxes.count) \(mealWord)"
    }
}
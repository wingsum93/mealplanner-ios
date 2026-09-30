import Foundation

enum PlanScheduleMutation {
    static func hasMeals(on date: Date, in plan: ProcurementPlan, calendar: Calendar = .current) -> Bool {
        let day = calendar.startOfDay(for: date)
        return calendar.startOfDay(for: plan.startDate) <= day
            && day <= calendar.startOfDay(for: plan.endDate)
            && plan.slots.contains { calendar.isDate($0.date, inSameDayAs: day) }
    }

    static func validDestinations(
        for sourceId: UUID,
        in plan: ProcurementPlan,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [(date: Date, timebox: PlanTimebox, occupied: Bool)] {
        guard let source = plan.slots.first(where: { $0.id == sourceId }),
              calendar.startOfDay(for: source.date) >= calendar.startOfDay(for: now) else { return [] }
        let first = max(calendar.startOfDay(for: plan.startDate), calendar.startOfDay(for: now))
        let last = calendar.startOfDay(for: plan.endDate)
        guard first <= last else { return [] }
        var results: [(Date, PlanTimebox, Bool)] = []
        var date = first
        while date <= last {
            if hasMeals(on: date, in: plan, calendar: calendar) {
                for timebox in PlanTimebox.allCases where plan.availableTimeboxes.contains(timebox) {
                    guard !calendar.isDate(source.date, inSameDayAs: date) || source.timebox != timebox else { continue }
                    let occupant = plan.slots.first {
                        calendar.isDate($0.date, inSameDayAs: date) && $0.timebox == timebox
                    }
                    if let occupant, calendar.startOfDay(for: occupant.date) < calendar.startOfDay(for: now) { continue }
                    results.append((date, timebox, occupant != nil))
                }
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }
        return results
    }

    static func move(
        sourceId: UUID,
        to date: Date,
        timebox: PlanTimebox,
        in plan: ProcurementPlan,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> ProcurementPlan? {
        guard validDestinations(for: sourceId, in: plan, now: now, calendar: calendar).contains(where: {
            calendar.isDate($0.date, inSameDayAs: date) && $0.timebox == timebox
        }), let sourceIndex = plan.slots.firstIndex(where: { $0.id == sourceId }) else { return nil }
        var updated = plan
        let destinationIndex = updated.slots.firstIndex {
            calendar.isDate($0.date, inSameDayAs: date) && $0.timebox == timebox
        }
        let sourceDate = updated.slots[sourceIndex].date
        let sourceTimebox = updated.slots[sourceIndex].timebox
        if let destinationIndex {
            updated.slots[destinationIndex].date = sourceDate
            updated.slots[destinationIndex].timebox = sourceTimebox
        }
        updated.slots[sourceIndex].date = calendar.startOfDay(for: date)
        updated.slots[sourceIndex].timebox = timebox
        return updated
    }
}

import SwiftUI

struct PlanMonthCalendar: View {
    let plan: ProcurementPlan
    @Binding var month: Date
    let onSelect: (Date) -> Void
    var onDropDate: ((Date, UUID) -> Bool)? = nil

    private var calendar: Calendar { .current }

    var body: some View {
        let snapshot = PlanCalendarSnapshot(plan: plan, month: month, calendar: calendar)

        VStack(spacing: 12) {
            HStack {
                Button { changeMonth(-1) } label: { Image(systemName: "chevron.left") }
                    .disabled(month <= snapshot.firstMonth)
                    .accessibilityLabel("Previous month")
                    .accessibilityIdentifier("planCalendar.previous")
                Spacer()
                Text(snapshot.monthTitle).font(.headline)
                Spacer()
                Button { changeMonth(1) } label: { Image(systemName: "chevron.right") }
                    .disabled(month >= snapshot.lastMonth)
                    .accessibilityLabel("Next month")
                    .accessibilityIdentifier("planCalendar.next")
            }
            HStack {
                ForEach(snapshot.weekdaySymbols.indices, id: \.self) { index in
                    Text(snapshot.weekdaySymbols[index])
                        .font(.caption).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(snapshot.days) { day in
                    if let date = day.date {
                        dayCell(day, date: date)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func dayCell(_ day: PlanCalendarDay, date: Date) -> some View {
        let label = VStack(spacing: 2) {
            Text(day.dayTitle).font(.subheadline.weight(day.isEnabled ? .semibold : .regular))
            HStack(spacing: 2) {
                ForEach(PlanTimebox.allCases) { box in
                    Circle().fill(day.timeboxes.contains(box) ? Color.accentColor : .clear)
                        .frame(width: 4, height: 4)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(day.isEnabled ? Color.accentColor.opacity(0.12) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        return Button { onSelect(date) } label: { label }
        .buttonStyle(.plain)
        .foregroundStyle(day.isEnabled ? .primary : .tertiary)
        .disabled(!day.isEnabled)
        .accessibilityLabel(day.accessibilityLabel)
        .accessibilityValue(day.isEnabled ? "Planned meals" : "No planned meals")
        .accessibilityIdentifier("planCalendar.day.\(day.dayNumber)")
        .dropDestination(for: String.self) { items, _ in
            guard day.isEnabled, let raw = items.first, let sourceId = UUID(uuidString: raw) else { return false }
            return onDropDate?(date, sourceId) ?? false
        }
    }

    private func changeMonth(_ step: Int) {
        let snapshot = PlanCalendarSnapshot(plan: plan, month: month, calendar: calendar)
        guard let next = calendar.date(byAdding: .month, value: step, to: month),
              next >= snapshot.firstMonth, next <= snapshot.lastMonth else { return }
        month = next
    }
}

struct PlanCalendarDay: Identifiable, Equatable {
    let id: Int
    let date: Date?
    let dayNumber: Int
    let dayTitle: String
    let accessibilityLabel: String
    let isEnabled: Bool
    let timeboxes: Set<PlanTimebox>
}

struct PlanCalendarSnapshot: Equatable {
    let firstMonth: Date
    let lastMonth: Date
    let monthTitle: String
    let weekdaySymbols: [String]
    let days: [PlanCalendarDay]

    init(plan: ProcurementPlan, month: Date, calendar: Calendar = .current) {
        firstMonth = Self.monthStart(for: plan.startDate, calendar: calendar)
        lastMonth = Self.monthStart(for: plan.endDate, calendar: calendar)
        monthTitle = month.formatted(.dateTime.month(.wide).year())
        weekdaySymbols = (0..<7).map { index in
            calendar.veryShortStandaloneWeekdaySymbols[(calendar.firstWeekday - 1 + index) % 7]
        }

        let slotsByDay = Dictionary(grouping: plan.slots) { slot in
            calendar.startOfDay(for: slot.date)
        }
        let timeboxesByDay = slotsByDay.mapValues { slots in
            Set(slots.map(\.timebox))
        }
        guard let interval = calendar.dateInterval(of: .month, for: month) else {
            days = []
            return
        }

        let offset = (calendar.component(.weekday, from: interval.start) - calendar.firstWeekday + 7) % 7
        let emptyDays = (0..<offset).map { index in
            PlanCalendarDay(
                id: index,
                date: nil,
                dayNumber: 0,
                dayTitle: "",
                accessibilityLabel: "",
                isEnabled: false,
                timeboxes: []
            )
        }
        let dayCount = calendar.range(of: .day, in: .month, for: month)?.count ?? 0
        let plannedDays = (0..<dayCount).compactMap { index -> PlanCalendarDay? in
            guard let date = calendar.date(byAdding: .day, value: index, to: interval.start) else { return nil }
            let day = calendar.startOfDay(for: date)
            let timeboxes = timeboxesByDay[day] ?? []
            let isInPlanRange = calendar.startOfDay(for: plan.startDate) <= day
                && day <= calendar.startOfDay(for: plan.endDate)
            return PlanCalendarDay(
                id: offset + index,
                date: date,
                dayNumber: calendar.component(.day, from: date),
                dayTitle: date.formatted(.dateTime.day()),
                accessibilityLabel: date.formatted(date: .complete, time: .omitted),
                isEnabled: isInPlanRange && !timeboxes.isEmpty,
                timeboxes: timeboxes
            )
        }
        days = emptyDays + plannedDays
    }

    private static func monthStart(for date: Date, calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }
}

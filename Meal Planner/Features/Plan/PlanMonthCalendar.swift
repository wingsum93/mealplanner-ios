import SwiftUI

struct PlanMonthCalendar: View {
    let plan: ProcurementPlan
    @Binding var month: Date
    let onSelect: (Date) -> Void
    var onDropDate: ((Date, UUID) -> Bool)? = nil

    private var calendar: Calendar { .current }

    private var firstMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: plan.startDate)) ?? plan.startDate
    }

    private var lastMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: plan.endDate)) ?? plan.endDate
    }

    private var days: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let offset = (calendar.component(.weekday, from: interval.start) - calendar.firstWeekday + 7) % 7
        let count = calendar.range(of: .day, in: .month, for: month)?.count ?? 0
        return Array(repeating: nil, count: offset) + (0..<count).map {
            calendar.date(byAdding: .day, value: $0, to: interval.start)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button { changeMonth(-1) } label: { Image(systemName: "chevron.left") }
                    .disabled(month <= firstMonth)
                    .accessibilityLabel("Previous month")
                    .accessibilityIdentifier("planCalendar.previous")
                Spacer()
                Text(month.formatted(.dateTime.month(.wide).year())).font(.headline)
                Spacer()
                Button { changeMonth(1) } label: { Image(systemName: "chevron.right") }
                    .disabled(month >= lastMonth)
                    .accessibilityLabel("Next month")
                    .accessibilityIdentifier("planCalendar.next")
            }
            let symbols = calendar.veryShortStandaloneWeekdaySymbols
            HStack {
                ForEach(0..<7, id: \.self) { index in
                    Text(symbols[(calendar.firstWeekday - 1 + index) % 7])
                        .font(.caption).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(date)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func dayCell(_ date: Date) -> some View {
        let enabled = PlanScheduleMutation.hasMeals(on: date, in: plan)
        let slots = plan.slots.filter { calendar.isDate($0.date, inSameDayAs: date) }
        let label = VStack(spacing: 2) {
            Text(date.formatted(.dateTime.day())).font(.subheadline.weight(enabled ? .semibold : .regular))
            HStack(spacing: 2) {
                ForEach(PlanTimebox.allCases) { box in
                    Circle().fill(slots.contains { $0.timebox == box } ? Color.accentColor : .clear)
                        .frame(width: 4, height: 4)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(enabled ? Color.accentColor.opacity(0.12) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        return Button { onSelect(date) } label: { label }
        .buttonStyle(.plain)
        .foregroundStyle(enabled ? .primary : .tertiary)
        .disabled(!enabled)
        .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
        .accessibilityValue(enabled ? "Planned meals" : "No planned meals")
        .accessibilityIdentifier("planCalendar.day.\(calendar.component(.day, from: date))")
        .dropDestination(for: String.self) { items, _ in
            guard enabled, let raw = items.first, let sourceId = UUID(uuidString: raw) else { return false }
            return onDropDate?(date, sourceId) ?? false
        }
    }

    private func changeMonth(_ step: Int) {
        guard let next = calendar.date(byAdding: .month, value: step, to: month),
              next >= firstMonth, next <= lastMonth else { return }
        month = next
    }
}

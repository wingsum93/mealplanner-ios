//
//  Step3ScheduleView.swift
//  Meal Planner
//
//  Step 3 — schedule review & adjustments (FR §5.4).
//

import SwiftUI

struct Step3ScheduleView: View {
    @ObservedObject var vm: PlanViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Button {
                    vm.onIntent(.shuffleSchedule)
                } label: {
                    Label("Shuffle", systemImage: "shuffle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("planWizard.shuffle")

                Button {
                    vm.onIntent(.generateSchedule)
                } label: {
                    Label("Regenerate", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("planWizard.regenerate")
            }

            if vm.state.schedule.isEmpty {
                EmptyStateView(
                    title: "No schedule yet",
                    description: "Go back and pick at least one meal.",
                    systemImage: "calendar"
                )
                .frame(minHeight: 220)
            } else {
                ForEach(vm.state.mealSlotsByDay, id: \.date) { group in
                    daySection(date: group.date, slots: group.slots)
                }
            }
        }
    }

    private func daySection(date: Date, slots: [PlanSlot]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(Self.dayText(date))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button(role: .destructive) {
                    vm.onIntent(.clearDay(date))
                } label: {
                    Text("Clear day")
                        .font(.caption)
                }
            }

            ForEach(slots) { slot in
                slotRow(slot)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private func slotRow(_ slot: PlanSlot) -> some View {
        Menu {
            ForEach(vm.state.selectedMealIds.sorted(), id: \.self) { mealId in
                Button {
                    vm.onIntent(.replaceSlot(slotId: slot.id, mealId: mealId))
                } label: {
                    Text(vm.state.meal(id: mealId)?.name ?? "Meal #\(mealId)")
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: slot.timebox.systemImage)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(slot.timebox.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(vm.state.meal(id: slot.mealId)?.name ?? "Meal #\(slot.mealId)")
                        .font(.body)
                        .foregroundStyle(.primary)
                }

                Spacer()

                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .accessibilityIdentifier("planWizard.slot.\(slot.id.uuidString)")
    }

    private static func dayText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}
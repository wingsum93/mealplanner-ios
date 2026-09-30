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
        let mealLookup = vm.state.mealsById
        let selectedMealIds = vm.state.selectedMealIdsSorted

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
                    ScheduleDaySection(
                        date: group.date,
                        slots: group.slots,
                        selectedMealIds: selectedMealIds,
                        mealLookup: mealLookup,
                        onClearDay: { vm.onIntent(.clearDay(group.date)) },
                        onReplaceSlot: { slotId, mealId in
                            vm.onIntent(.replaceSlot(slotId: slotId, mealId: mealId))
                        }
                    )
                    .equatable()
                }
            }
        }
    }
}

private struct ScheduleDaySection: View, Equatable {
    let date: Date
    let slots: [PlanSlot]
    let selectedMealIds: [Int64]
    let mealLookup: [Int64: UIRecipeItem]
    let onClearDay: () -> Void
    let onReplaceSlot: (UUID, Int64) -> Void

    static func == (lhs: ScheduleDaySection, rhs: ScheduleDaySection) -> Bool {
        lhs.date == rhs.date
            && lhs.slots == rhs.slots
            && lhs.selectedMealIds == rhs.selectedMealIds
            && lhs.mealLookup == rhs.mealLookup
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(Self.dayText(date))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button(role: .destructive, action: onClearDay) {
                    Text("Clear day")
                        .font(.caption)
                }
            }

            ForEach(slots) { slot in
                ScheduleSlotRow(
                    slot: slot,
                    selectedMealIds: selectedMealIds,
                    mealLookup: mealLookup,
                    onReplaceSlot: onReplaceSlot
                )
                .equatable()
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

private struct ScheduleSlotRow: View, Equatable {
    let slot: PlanSlot
    let selectedMealIds: [Int64]
    let mealLookup: [Int64: UIRecipeItem]
    let onReplaceSlot: (UUID, Int64) -> Void

    static func == (lhs: ScheduleSlotRow, rhs: ScheduleSlotRow) -> Bool {
        lhs.slot == rhs.slot
            && lhs.selectedMealIds == rhs.selectedMealIds
            && lhs.mealLookup == rhs.mealLookup
    }

    var body: some View {
        Menu {
            ForEach(selectedMealIds, id: \.self) { mealId in
                Button {
                    onReplaceSlot(slot.id, mealId)
                } label: {
                    Text(mealLookup[mealId]?.name ?? "Meal #\(mealId)")
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
                    Text(mealLookup[slot.mealId]?.name ?? "Meal #\(slot.mealId)")
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
}

private extension ScheduleDaySection {
    private static func dayText(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }
}

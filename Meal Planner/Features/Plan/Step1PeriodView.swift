//
//  Step1PeriodView.swift
//  Meal Planner
//
//  Step 1 — period (date range) & timeboxes (FR §5.2).
//

import SwiftUI

struct Step1PeriodView: View {
    @ObservedObject var vm: PlanViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            card {
                DatePicker(
                    "Start date",
                    selection: Binding(
                        get: { vm.state.startDate },
                        set: { vm.onIntent(.setStartDate($0)) }
                    ),
                    displayedComponents: .date
                )
                .accessibilityIdentifier("planWizard.startDate")

                Divider()

                DatePicker(
                    "End date",
                    selection: Binding(
                        get: { vm.state.endDate },
                        set: { vm.onIntent(.setEndDate($0)) }
                    ),
                    in: vm.state.startDate...,
                    displayedComponents: .date
                )
                .accessibilityIdentifier("planWizard.endDate")
            }

            Text(vm.state.slotCaption)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .accessibilityIdentifier("planWizard.slotCaption")

            Text("Ranges are limited to 7–31 days.")
                .font(.caption)
                .foregroundStyle(.secondary)

            card {
                Text("Meals per day")
                    .font(.subheadline.weight(.semibold))

                ForEach(PlanTimebox.allCases) { timebox in
                    Toggle(isOn: Binding(
                        get: { vm.state.timeboxes.contains(timebox) },
                        set: { _ in vm.onIntent(.toggleTimebox(timebox)) }
                    )) {
                        Label(timebox.title, systemImage: timebox.systemImage)
                    }
                    .accessibilityIdentifier("planWizard.timebox.\(timebox.rawValue)")
                }

                Text("Breakfast is not part of the plan yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}
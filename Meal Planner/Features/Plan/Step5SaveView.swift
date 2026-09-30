//
//  Step5SaveView.swift
//  Meal Planner
//
//  Step 5 — name & save the plan (FR §5.6).
//

import SwiftUI

struct Step5SaveView: View {
    @ObservedObject var vm: PlanViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Plan name")
                    .font(.subheadline.weight(.semibold))
                TextField("Plan name", text: Binding(
                    get: { vm.state.planName },
                    set: { vm.onIntent(.setPlanName($0)) }
                ))
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("planWizard.planName")
            }

            summary
        }
    }

    private var summary: some View {
        SavePlanSummary(
            dayCount: vm.state.dayCount,
            scheduleCount: vm.state.schedule.count,
            ingredientCount: vm.state.ingredients.count,
            checkedIngredientCount: vm.state.checkedIngredientCount,
            dateRange: dateRange
        )
    }

    private var dateRange: String {
        let dates = vm.state.dayDates
        guard let first = dates.first, let last = dates.last else { return "" }
        let start = first.formatted(.dateTime.month(.abbreviated).day())
        let end = last.formatted(.dateTime.month(.abbreviated).day())
        return "\(start) – \(end)"
    }
}

private struct SavePlanSummary: View {
    let dayCount: Int
    let scheduleCount: Int
    let ingredientCount: Int
    let checkedIngredientCount: Int
    let dateRange: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SavePlanSummaryRow(icon: "calendar", title: "\(dayCount) days", subtitle: dateRange)
            Divider()
            SavePlanSummaryRow(icon: "fork.knife", title: "\(scheduleCount) meals", subtitle: "All slots filled")
            Divider()
            SavePlanSummaryRow(
                icon: "cart",
                title: "\(ingredientCount) ingredients",
                subtitle: "\(checkedIngredientCount) checked"
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

private struct SavePlanSummaryRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

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
        VStack(alignment: .leading, spacing: 12) {
            summaryRow(icon: "calendar", title: "\(vm.state.dayCount) days",
                       subtitle: dateRange)
            Divider()
            summaryRow(icon: "fork.knife", title: "\(vm.state.schedule.count) meals",
                       subtitle: "All slots filled")
            Divider()
            summaryRow(icon: "cart", title: "\(vm.state.ingredients.count) ingredients",
                       subtitle: "\(vm.state.checkedIngredientCount) checked")
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private func summaryRow(icon: String, title: String, subtitle: String) -> some View {
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

    private var dateRange: String {
        let dates = vm.state.dayDates
        guard let first = dates.first, let last = dates.last else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: first)) – \(formatter.string(from: last))"
    }
}
//
//  PlanDetailView.swift
//  Meal Planner
//
//  Saved plan detail: schedule + procurement (ingredient) checklist.
//

import SwiftUI

struct PlanDetailView: View {
    let planId: UUID
    @EnvironmentObject private var vm: PlanViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteConfirm = false

    private var plan: ProcurementPlan? { vm.plan(id: planId) }

    var body: some View {
        Group {
            if let plan {
                content(plan)
            } else {
                Text("This plan is no longer available.")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .navigationTitle(plan?.name ?? "Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        vm.onIntent(.copyPlan(planId))
                    } label: {
                        Label("Copy as new", systemImage: "doc.on.doc")
                    }
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityIdentifier("planDetail.menu")
            }
        }
        .confirmationDialog(
            "Delete this plan?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                vm.onIntent(.deletePlan(planId))
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    private func content(_ plan: ProcurementPlan) -> some View {
        List {
            Section("Schedule") {
                ForEach(plan.mealInstanceCount > 0 ? plan.slots.sorted { $0.displayOrder < $1.displayOrder } : [], id: \.id) { slot in
                    slotRow(slot, in: plan)
                }
            }

            Section("Ingredients · \(plan.checkedIngredientCount)/\(plan.ingredients.count)") {
                if plan.ingredients.isEmpty {
                    Text("No ingredients for this plan.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(IngredientCategory.allCases) { category in
                        let items = plan.ingredients.filter { $0.category == category }
                        if !items.isEmpty {
                            ingredientHeader(category)
                            ForEach(items) { ingredient in
                                ingredientRow(ingredient)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .accessibilityIdentifier("planDetail.list")
    }

    private func slotRow(_ slot: PlanSlot, in plan: ProcurementPlan) -> some View {
        HStack(spacing: 12) {
            Image(systemName: slot.timebox.systemImage)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(slot.timebox.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(mealTitle(slot.mealId, in: plan))
                    .font(.body)
            }
            Spacer()
            Text(Self.dayText(slot.date))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private func ingredientHeader(_ category: IngredientCategory) -> some View {
        Label(category.title, systemImage: category.systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private func ingredientRow(_ ingredient: PlanIngredient) -> some View {
        Button {
            vm.onIntent(.toggleSavedIngredient(
                planId: planId,
                ingredientId: ingredient.id,
                isChecked: !ingredient.isChecked
            ))
        } label: {
            HStack(spacing: 12) {
                Image(systemName: ingredient.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(ingredient.isChecked ? Color.accentColor : Color.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ingredient.name)
                        .strikethrough(ingredient.isChecked)
                        .foregroundStyle(ingredient.isChecked ? .secondary : .primary)
                    if !ingredient.quantityText.isEmpty {
                        Text(ingredient.quantityText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if ingredient.occurrenceCount > 1 {
                    Text("×\(ingredient.occurrenceCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func mealTitle(_ mealId: Int64, in plan: ProcurementPlan) -> String {
        // The plan stores ids only; titles are resolved from the current tab
        // sources when the same meal is still known, otherwise the id is shown.
        let key = String(mealId)
        if let ui = (vm.state.meal(id: mealId)) { return ui.name }
        return "Meal #\(key)"
    }

    private static func dayText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d"
        return formatter.string(from: date)
    }
}
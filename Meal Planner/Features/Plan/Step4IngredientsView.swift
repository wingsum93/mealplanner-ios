//
//  Step4IngredientsView.swift
//  Meal Planner
//
//  Step 4 — aggregated procurement list grouped into 5 categories (FR §5.5).
//

import SwiftUI

struct Step4IngredientsView: View {
    @ObservedObject var vm: PlanViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(vm.state.ingredients.count) items · \(vm.state.checkedIngredientCount) checked")
                .font(.subheadline.weight(.semibold))
                .accessibilityIdentifier("planWizard.ingredientCount")

            if vm.state.ingredients.isEmpty {
                EmptyStateView(
                    title: "No ingredients",
                    description: "The planned meals have no tagged ingredients. You can still save the plan.",
                    systemImage: "cart"
                )
                .frame(minHeight: 220)
                .accessibilityIdentifier("planWizard.ingredientsEmpty")
            } else {
                ForEach(vm.state.ingredientGroups, id: \.category) { group in
                    categorySection(group.category, items: group.items)
                }
            }
        }
    }

    private func categorySection(_ category: IngredientCategory, items: [PlanIngredient]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                vm.onIntent(.toggleCategory(category))
            } label: {
                HStack {
                    Label(category.title, systemImage: category.systemImage)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(items.filter(\.isChecked).count)/\(items.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("planWizard.category.\(category.rawValue)")

            ForEach(items) { ingredient in
                ingredientRow(ingredient)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private func ingredientRow(_ ingredient: PlanIngredient) -> some View {
        Button {
            vm.onIntent(.toggleIngredient(ingredient.id))
        } label: {
            HStack(spacing: 12) {
                Image(systemName: ingredient.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(ingredient.isChecked ? Color.accentColor : Color.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ingredient.name)
                        .foregroundStyle(.primary)
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
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("planWizard.ingredient.\(ingredient.name)")
    }
}
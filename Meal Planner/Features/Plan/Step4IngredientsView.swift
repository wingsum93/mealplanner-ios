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
        let ingredientGroups = vm.state.ingredientGroups

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
                ForEach(ingredientGroups, id: \.category) { group in
                    IngredientCategorySection(
                        category: group.category,
                        items: group.items,
                        onToggleCategory: { vm.onIntent(.toggleCategory(group.category)) },
                        onToggleIngredient: { vm.onIntent(.toggleIngredient($0)) }
                    )
                    .equatable()
                }
            }
        }
    }
}

private struct IngredientCategorySection: View, Equatable {
    let category: IngredientCategory
    let items: [PlanIngredient]
    let onToggleCategory: () -> Void
    let onToggleIngredient: (UUID) -> Void

    static func == (lhs: IngredientCategorySection, rhs: IngredientCategorySection) -> Bool {
        lhs.category == rhs.category && lhs.items == rhs.items
    }

    private var checkedCount: Int {
        items.reduce(into: 0) { count, ingredient in
            if ingredient.isChecked {
                count += 1
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onToggleCategory) {
                HStack {
                    Label(category.title, systemImage: category.systemImage)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(checkedCount)/\(items.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("planWizard.category.\(category.rawValue)")

            ForEach(items) { ingredient in
                PlanIngredientRow(
                    ingredient: ingredient,
                    onToggle: { onToggleIngredient(ingredient.id) }
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

private struct PlanIngredientRow: View, Equatable {
    let ingredient: PlanIngredient
    let onToggle: () -> Void

    static func == (lhs: PlanIngredientRow, rhs: PlanIngredientRow) -> Bool {
        lhs.ingredient == rhs.ingredient
    }

    var body: some View {
        Button(action: onToggle) {
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

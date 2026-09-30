import SwiftUI

struct PlanIngredientsView: View {
    let planId: UUID
    @EnvironmentObject private var vm: PlanViewModel
    @State private var category: IngredientCategory = .meat

    var body: some View {
        Group {
            if let plan = vm.plan(id: planId) {
                let items = visibleIngredients(in: plan)

                VStack(spacing: 0) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(IngredientCategory.allCases) { item in
                                Button(item.title) { category = item }
                                    .buttonStyle(.bordered)
                                    .tint(category == item ? .accentColor : .gray)
                                    .accessibilityIdentifier("planIngredients.tab.\(item.title)")
                            }
                        }
                        .padding()
                    }
                    if items.isEmpty {
                        ContentUnavailableView("No \(category.title.lowercased()) ingredients", systemImage: category.systemImage)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(items) { ingredient in
                                    SavedIngredientRow(ingredient: ingredient) {
                                        vm.onIntent(.toggleSavedIngredient(
                                            planId: planId,
                                            ingredientId: ingredient.id,
                                            isChecked: !ingredient.isChecked
                                        ))
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            } else if case .error(let message) = vm.state.phase {
                ErrorView(message: message) { vm.onIntent(.loadPlans) }
            } else {
                ContentUnavailableView("Plan unavailable", systemImage: "basket")
            }
        }
        .navigationTitle("Ingredients")
    }

    private func visibleIngredients(in plan: ProcurementPlan) -> [PlanIngredient] {
        plan.ingredients
            .filter { $0.category == category }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

private struct SavedIngredientRow: View {
    let ingredient: PlanIngredient
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: ingredient.isChecked ? "checkmark.circle.fill" : "circle")
                VStack(alignment: .leading) {
                    Text(ingredient.name).strikethrough(ingredient.isChecked)
                    if !ingredient.quantityText.isEmpty {
                        Text(ingredient.quantityText).font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if ingredient.occurrenceCount > 1 {
                    Text("×\(ingredient.occurrenceCount)").foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityValue(ingredient.isChecked ? "Checked" : "Unchecked")
        .accessibilityIdentifier("planIngredients.item.\(ingredient.id.uuidString)")
    }
}

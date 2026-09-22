//
//  Step2MealPickerView.swift
//  Meal Planner
//
//  Step 2 — meal selection (FR §5.3).
//

import SwiftUI
import Kingfisher

struct Step2MealPickerView: View {
    @ObservedObject var vm: PlanViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Source", selection: Binding(
                get: { vm.state.selectedTab },
                set: { vm.onIntent(.selectTab($0)) }
            )) {
                ForEach(PlanSourceTab.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("planWizard.sourceTab")

            header

            if vm.state.isLoadingMeals {
                ProgressView("Loading your meals…")
                    .frame(maxWidth: .infinity, minHeight: 160)
            } else if vm.state.currentTabMeals.isEmpty {
                emptyTab
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(vm.state.currentTabMeals) { item in
                        mealRow(item)
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(vm.state.selectedMealCount) of \(vm.state.slotCount) slots filled")
                .font(.subheadline.weight(.semibold))
                .accessibilityIdentifier("planWizard.slotsFilled")
            Text("Pick the meals you want. Repeats fill any remaining slots.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if vm.state.selectedTab == .random {
                Button {
                    vm.onIntent(.regenerateRandom)
                } label: {
                    Label("Surprise me again", systemImage: "arrow.clockwise")
                        .font(.subheadline)
                }
                .padding(.top, 4)
                .accessibilityIdentifier("planWizard.regenerateRandom")
            }
        }
    }

    private var emptyTab: some View {
        EmptyStateView(
            title: "Nothing here yet",
            description: "This list is empty. Try another tab or add meals from the Recipe tab.",
            systemImage: "fork.knife",
            actionTitle: "Try Random",
            onAction: { vm.onIntent(.selectTab(.random)) }
        )
        .frame(minHeight: 220)
        .accessibilityIdentifier("planWizard.emptyTab")
    }

    private func mealRow(_ item: UIRecipeItem) -> some View {
        let selected = vm.state.isSelected(Int64(item.id) ?? -1)
        return Button {
            if let id = Int64(item.id) {
                vm.onIntent(.toggleMeal(id))
            }
        } label: {
            HStack(spacing: 12) {
                KFImage(item.thumbURL)
                    .placeholder { Color.gray.opacity(0.3) }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    if let area = item.area, !area.isEmpty {
                        Text(area)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selected ? Color.accentColor : Color.secondary)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("planWizard.mealRow.\(item.id)")
    }
}
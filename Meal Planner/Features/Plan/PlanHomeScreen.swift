//
//  PlanHomeScreen.swift
//  Meal Planner
//
//  New Home tab: saved procurement plans + entry to the planning wizard.
//

import SwiftUI

struct PlanHomeScreen: View {
    @EnvironmentObject private var vm: PlanViewModel
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle("Meal Plans")
                .navigationDestination(for: UUID.self) { planId in
                    PlanDetailView(planId: planId)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            vm.onIntent(.openWizard)
                        } label: {
                            Label("New Plan", systemImage: "plus")
                        }
                        .accessibilityIdentifier("planHome.newPlan")
                    }
                }
                .task {
                    if vm.state.phase == .idle {
                        vm.onIntent(.loadPlans)
                    }
                }
        }
        .fullScreenCover(isPresented: wizardBinding) {
            MealPlanWizardView(vm: vm)
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { vm.state.errorMessage != nil },
                set: { if !$0 { vm.onIntent(.clearError) } }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.state.errorMessage ?? "")
        }
    }

    private var wizardBinding: Binding<Bool> {
        Binding(
            get: { vm.state.isWizardPresented },
            set: { if !$0 { vm.onIntent(.closeWizard) } }
        )
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state.phase {
        case .idle, .loading:
            ProgressView("Loading your plans…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier("planHome.loading")
        case .empty, .content:
            if vm.state.plans.isEmpty {
                emptyState
            } else {
                planList
            }
        case .error(let message):
            ErrorView(message: message) {
                vm.onIntent(.loadPlans)
            }
            .accessibilityIdentifier("planHome.error")
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            title: "No meal plans yet",
            description: "Plan your week and turn it into a shopping list.",
            systemImage: "calendar.badge.plus",
            actionTitle: "New Meal Plan",
            onAction: { vm.onIntent(.openWizard) }
        )
        .accessibilityIdentifier("planHome.empty")
    }

    private var planList: some View {
        ScrollView {
            VStack(spacing: 16) {
                newPlanButton

                ForEach(vm.state.plans) { plan in
                    Button {
                        path.append(plan.id)
                    } label: {
                        PlanCard(plan: plan)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("planHome.card.\(plan.id.uuidString)")
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .refreshable { vm.onIntent(.loadPlans) }
    }

    private var newPlanButton: some View {
        Button {
            vm.onIntent(.openWizard)
        } label: {
            Label("New Meal Plan", systemImage: "plus.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier("planHome.newPlanButton")
    }
}

private struct PlanCard: View {
    let plan: ProcurementPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(plan.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text(Self.rangeText(plan))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label("\(plan.dayCount) days", systemImage: "calendar")
                Label("\(plan.mealInstanceCount) meals", systemImage: "fork.knife")
                Label("\(plan.ingredients.count) items", systemImage: "cart")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .labelStyle(.titleAndIcon)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    static func rangeText(_ plan: ProcurementPlan) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: plan.startDate)) – \(formatter.string(from: plan.endDate))"
    }
}
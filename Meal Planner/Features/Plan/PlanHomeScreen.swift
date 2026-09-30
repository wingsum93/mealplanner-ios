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
            PlanHomeContent(
                phase: vm.state.phase,
                plans: vm.state.plans,
                onLoadPlans: { vm.onIntent(.loadPlans) },
                onOpenWizard: { vm.onIntent(.openWizard) },
                onSelectPlan: { path.append($0) }
            )
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
}

private struct PlanHomeContent: View {
    let phase: LoadPhase
    let plans: [ProcurementPlan]
    let onLoadPlans: () -> Void
    let onOpenWizard: () -> Void
    let onSelectPlan: (UUID) -> Void

    var body: some View {
        switch phase {
        case .idle, .loading:
            ProgressView("Loading your plans…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier("planHome.loading")
        case .empty, .content:
            if plans.isEmpty {
                PlanHomeEmptyState(onOpenWizard: onOpenWizard)
            } else {
                PlanList(
                    plans: plans,
                    onOpenWizard: onOpenWizard,
                    onSelectPlan: onSelectPlan,
                    onRefresh: onLoadPlans
                )
            }
        case .error(let message):
            ErrorView(message: message) {
                onLoadPlans()
            }
            .accessibilityIdentifier("planHome.error")
        }
    }
}

private struct PlanHomeEmptyState: View {
    let onOpenWizard: () -> Void

    var body: some View {
        EmptyStateView(
            title: "No meal plans yet",
            description: "Plan your week and turn it into a shopping list.",
            systemImage: "calendar.badge.plus",
            actionTitle: "New Meal Plan",
            onAction: onOpenWizard
        )
        .accessibilityIdentifier("planHome.empty")
    }
}

private struct PlanList: View {
    let plans: [ProcurementPlan]
    let onOpenWizard: () -> Void
    let onSelectPlan: (UUID) -> Void
    let onRefresh: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                NewPlanButton(action: onOpenWizard)

                ForEach(plans) { plan in
                    Button {
                        onSelectPlan(plan.id)
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
        .refreshable { onRefresh() }
    }
}

private struct NewPlanButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
        let start = plan.startDate.formatted(.dateTime.month(.abbreviated).day())
        let end = plan.endDate.formatted(.dateTime.month(.abbreviated).day())
        return "\(start) – \(end)"
    }
}

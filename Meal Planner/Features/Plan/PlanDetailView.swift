import SwiftUI

struct PlanDetailView: View {
    let planId: UUID
    @EnvironmentObject private var vm: PlanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false
    @State private var month = Date()
    @State private var selectedDate: Date?

    private var plan: ProcurementPlan? { vm.plan(id: planId) }

    var body: some View {
        Group {
            if let plan {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        PlanMonthCalendar(plan: plan, month: $month) { selectedDate = $0 }
                        PlanIngredientsNavigationLink(planId: planId, plan: plan)
                    }
                    .padding()
                }
                .navigationDestination(item: $selectedDate) { date in
                    PlanDayDetailView(planId: planId, date: date)
                }
            } else if vm.state.phase == .loading {
                ProgressView("Loading plan…")
            } else if case .error(let message) = vm.state.phase {
                ErrorView(message: message) { vm.onIntent(.loadPlans) }
            } else {
                ContentUnavailableView("Plan unavailable", systemImage: "calendar.badge.exclamationmark")
            }
        }
        .navigationTitle(plan?.name ?? "Plan")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let plan {
                month = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: plan.startDate)) ?? plan.startDate
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { vm.onIntent(.copyPlan(planId)) } label: {
                        Label("Copy as new", systemImage: "doc.on.doc")
                    }
                    Button(role: .destructive) { showDeleteConfirm = true } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: { Image(systemName: "ellipsis.circle") }
                .accessibilityIdentifier("planDetail.menu")
            }
        }
        .confirmationDialog("Delete this plan?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                vm.onIntent(.deletePlan(planId))
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

private struct PlanIngredientsNavigationLink: View {
    let planId: UUID
    let plan: ProcurementPlan

    var body: some View {
        NavigationLink {
            PlanIngredientsView(planId: planId)
        } label: {
            HStack {
                Label("Ingredients", systemImage: "basket")
                Spacer()
                Text("\(plan.ingredients.count) items · \(plan.checkedIngredientCount) checked")
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("planDetail.ingredients")
    }
}

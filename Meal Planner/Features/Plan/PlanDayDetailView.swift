import SwiftUI

struct PlanDayDetailView: View {
    let planId: UUID
    let date: Date
    @EnvironmentObject private var vm: PlanViewModel
    @State private var displayedDate: Date
    @State private var month: Date
    @State private var movingSlotId: UUID?
    @State private var pendingDrop: (sourceId: UUID, date: Date)?

    init(planId: UUID, date: Date) {
        self.planId = planId
        self.date = date
        _displayedDate = State(initialValue: date)
        _month = State(initialValue: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date)) ?? date)
    }

    var body: some View {
        Group {
            if let plan = vm.plan(id: planId) {
                let slots = plan.slots.filter { Calendar.current.isDate($0.date, inSameDayAs: displayedDate) }
                let availableTimeboxes = PlanTimebox.allCases.filter { plan.availableTimeboxes.contains($0) }

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        Text(displayedDate.formatted(date: .complete, time: .omitted))
                            .font(.title2.bold())
                        PlanMonthCalendar(plan: plan, month: $month, onSelect: { displayedDate = $0 }) { date, sourceId in
                            let valid = PlanScheduleMutation.validDestinations(for: sourceId, in: plan)
                                .contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
                            if valid { pendingDrop = (sourceId, date) }
                            return valid
                        }
                        if slots.isEmpty {
                            ContentUnavailableView("No meals for this day", systemImage: "fork.knife")
                        }
                        ForEach(availableTimeboxes) { box in
                            if let slot = slots.first(where: { $0.timebox == box }) {
                                mealCard(slot, plan: plan)
                            } else {
                                emptySlot(box, plan: plan)
                            }
                        }
                    }
                    .padding()
                }
                .sheet(isPresented: Binding(
                    get: { movingSlotId != nil }, set: { if !$0 { movingSlotId = nil } }
                )) {
                    if let id = movingSlotId {
                        PlanMoveDestinationSheet(planId: planId, sourceId: id)
                            .environmentObject(vm)
                    }
                }
                .confirmationDialog("Choose a timebox", isPresented: Binding(
                    get: { pendingDrop != nil }, set: { if !$0 { pendingDrop = nil } }
                )) {
                    if let pendingDrop {
                        ForEach(PlanTimebox.allCases) { box in
                            if PlanScheduleMutation.validDestinations(for: pendingDrop.sourceId, in: plan)
                                .contains(where: { Calendar.current.isDate($0.date, inSameDayAs: pendingDrop.date) && $0.timebox == box }) {
                                Button(box.title) {
                                    vm.onIntent(.moveSavedMeal(planId: planId, sourceId: pendingDrop.sourceId,
                                                                date: pendingDrop.date, timebox: box))
                                    self.pendingDrop = nil
                                }
                            }
                        }
                    }
                }
            } else if vm.state.phase == .loading {
                ProgressView("Loading day…")
            } else if case .error(let message) = vm.state.phase {
                ErrorView(message: message) { vm.onIntent(.loadPlans) }
            } else {
                ContentUnavailableView("Plan unavailable", systemImage: "calendar.badge.exclamationmark")
            }
        }
        .navigationTitle("Day Meals")
        .safeAreaInset(edge: .bottom) {
            if vm.state.undoPlanId == planId {
                HStack {
                    Text("Meal moved")
                    Spacer()
                    Button("Undo") { vm.onIntent(.undoSavedReorder(planId)) }
                        .accessibilityIdentifier("planDay.undo")
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    private func mealCard(_ slot: PlanSlot, plan: ProcurementPlan) -> some View {
        let snapshot = plan.snapshot(for: slot.mealId)
        let movable = Calendar.current.startOfDay(for: slot.date) >= Calendar.current.startOfDay(for: Date())
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(slot.timebox.title, systemImage: slot.timebox.systemImage)
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                if movable {
                    Button("Move") { movingSlotId = slot.id }
                        .accessibilityIdentifier("planDay.move.\(slot.id.uuidString)")
                } else {
                    Label("Past meal", systemImage: "lock").font(.caption)
                }
            }
            Text(snapshot?.title ?? "Meal #\(slot.mealId)")
                .font(.headline)
                .accessibilityIdentifier("planDay.meal.\(slot.id.uuidString)")
            if let snapshot {
                SavedMealIngredients(ingredients: snapshot.ingredients)
            } else {
                Text("Ingredient details were not saved with this older plan.")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .draggable(slot.id.uuidString)
        .dropDestination(for: String.self) { items, _ in
            guard let raw = items.first, let sourceId = UUID(uuidString: raw) else { return false }
            let valid = PlanScheduleMutation.validDestinations(for: sourceId, in: plan)
                .contains { Calendar.current.isDate($0.date, inSameDayAs: slot.date) && $0.timebox == slot.timebox }
            guard valid else { return false }
            vm.onIntent(.moveSavedMeal(planId: planId, sourceId: sourceId, date: slot.date, timebox: slot.timebox))
            return true
        }
    }

    private func emptySlot(_ box: PlanTimebox, plan: ProcurementPlan) -> some View {
        Text("\(box.title) · Empty")
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
            .accessibilityIdentifier("planDay.empty.\(box.rawValue)")
            .dropDestination(for: String.self) { items, _ in
                guard let raw = items.first, let sourceId = UUID(uuidString: raw) else { return false }
                let valid = PlanScheduleMutation.validDestinations(for: sourceId, in: plan)
                    .contains { Calendar.current.isDate($0.date, inSameDayAs: displayedDate) && $0.timebox == box }
                guard valid else { return false }
                vm.onIntent(.moveSavedMeal(planId: planId, sourceId: sourceId, date: displayedDate, timebox: box))
                return true
            }
    }
}

private struct SavedMealIngredients: View {
    let ingredients: [PlanMealIngredient]

    var body: some View {
        if ingredients.isEmpty {
            Text("No ingredients saved for this meal.")
                .foregroundStyle(.secondary)
        } else {
            ForEach(ingredients.indices, id: \.self) { index in
                let ingredient = ingredients[index]
                Text(ingredient.measure.isEmpty ? ingredient.name : "\(ingredient.name) · \(ingredient.measure)")
                    .font(.subheadline)
            }
        }
    }
}

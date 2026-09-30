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
                let snapshot = PlanDayDetailSnapshot(plan: plan, displayedDate: displayedDate)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        Text(snapshot.displayedDateTitle)
                            .font(.title2.bold())
                        PlanMonthCalendar(plan: plan, month: $month, onSelect: { displayedDate = $0 }) { date, sourceId in
                            let valid = snapshot.hasValidDestinationDate(for: sourceId, date: date)
                            if valid { pendingDrop = (sourceId, date) }
                            return valid
                        }
                        if snapshot.slots.isEmpty {
                            ContentUnavailableView("No meals for this day", systemImage: "fork.knife")
                        }
                        ForEach(snapshot.availableTimeboxes) { box in
                            if let slot = snapshot.slot(for: box) {
                                mealCard(slot, snapshot: snapshot)
                            } else {
                                emptySlot(box, snapshot: snapshot)
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
                            if snapshot.hasValidDestination(for: pendingDrop.sourceId, date: pendingDrop.date, timebox: box) {
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

    private func mealCard(_ slot: PlanDaySlotSnapshot, snapshot: PlanDayDetailSnapshot) -> some View {
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(slot.slot.timebox.title, systemImage: slot.slot.timebox.systemImage)
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                if slot.isMovable {
                    Button("Move") { movingSlotId = slot.slot.id }
                        .accessibilityIdentifier("planDay.move.\(slot.slot.id.uuidString)")
                } else {
                    Label("Past meal", systemImage: "lock").font(.caption)
                }
            }
            Text(slot.mealTitle)
                .font(.headline)
                .accessibilityIdentifier("planDay.meal.\(slot.slot.id.uuidString)")
            if let mealSnapshot = slot.mealSnapshot {
                SavedMealIngredients(ingredients: mealSnapshot.ingredients)
            } else {
                Text("Ingredient details were not saved with this older plan.")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .draggable(slot.slot.id.uuidString)
        .dropDestination(for: String.self) { items, _ in
            guard let raw = items.first, let sourceId = UUID(uuidString: raw) else { return false }
            let valid = snapshot.hasValidDestination(
                for: sourceId,
                date: slot.slot.date,
                timebox: slot.slot.timebox
            )
            guard valid else { return false }
            vm.onIntent(.moveSavedMeal(planId: planId, sourceId: sourceId, date: slot.slot.date, timebox: slot.slot.timebox))
            return true
        }
    }

    private func emptySlot(_ box: PlanTimebox, snapshot: PlanDayDetailSnapshot) -> some View {
        Text("\(box.title) · Empty")
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
            .accessibilityIdentifier("planDay.empty.\(box.rawValue)")
            .dropDestination(for: String.self) { items, _ in
                guard let raw = items.first, let sourceId = UUID(uuidString: raw) else { return false }
                let valid = snapshot.hasValidDestination(for: sourceId, date: snapshot.displayedDay, timebox: box)
                guard valid else { return false }
                vm.onIntent(.moveSavedMeal(planId: planId, sourceId: sourceId, date: snapshot.displayedDay, timebox: box))
                return true
            }
    }
}

struct PlanMoveDestinationKey: Hashable {
    let day: Date
    let timebox: PlanTimebox
}

struct PlanDaySlotSnapshot: Identifiable, Equatable {
    let slot: PlanSlot
    let mealSnapshot: PlanMealSnapshot?
    let isMovable: Bool

    var id: UUID { slot.id }
    var mealTitle: String { mealSnapshot?.title ?? "Meal #\(slot.mealId)" }
}

struct PlanDayDetailSnapshot: Equatable {
    let displayedDay: Date
    let displayedDateTitle: String
    let slots: [PlanDaySlotSnapshot]
    let availableTimeboxes: [PlanTimebox]

    private let slotsByTimebox: [PlanTimebox: PlanDaySlotSnapshot]
    private let validDestinationSets: [UUID: Set<PlanMoveDestinationKey>]

    init(plan: ProcurementPlan, displayedDate: Date, now: Date = Date(), calendar: Calendar = .current) {
        let day = calendar.startOfDay(for: displayedDate)
        displayedDay = day
        displayedDateTitle = displayedDate.formatted(date: .complete, time: .omitted)
        availableTimeboxes = PlanTimebox.allCases.filter { plan.availableTimeboxes.contains($0) }

        let mealSnapshotsByID = Dictionary(uniqueKeysWithValues: plan.mealSnapshots.map { ($0.id, $0) })
        let today = calendar.startOfDay(for: now)
        let daySlots = plan.slots
            .filter { calendar.isDate($0.date, inSameDayAs: day) }
            .sorted { $0.displayOrder < $1.displayOrder }
            .map { slot in
                PlanDaySlotSnapshot(
                    slot: slot,
                    mealSnapshot: mealSnapshotsByID[slot.mealId],
                    isMovable: calendar.startOfDay(for: slot.date) >= today
                )
            }

        slots = daySlots
        slotsByTimebox = Dictionary(uniqueKeysWithValues: daySlots.map { ($0.slot.timebox, $0) })
        validDestinationSets = Dictionary(uniqueKeysWithValues: daySlots.map { slot in
            let destinations = PlanScheduleMutation.validDestinations(
                for: slot.slot.id,
                in: plan,
                now: now,
                calendar: calendar
            )
            let keys = Set(destinations.map {
                PlanMoveDestinationKey(day: calendar.startOfDay(for: $0.date), timebox: $0.timebox)
            })
            return (slot.slot.id, keys)
        })
    }

    func slot(for timebox: PlanTimebox) -> PlanDaySlotSnapshot? {
        slotsByTimebox[timebox]
    }

    func hasValidDestinationDate(for sourceId: UUID, date: Date, calendar: Calendar = .current) -> Bool {
        guard let destinations = validDestinationSets[sourceId] else { return false }
        let day = calendar.startOfDay(for: date)
        return destinations.contains { $0.day == day }
    }

    func hasValidDestination(
        for sourceId: UUID,
        date: Date,
        timebox: PlanTimebox,
        calendar: Calendar = .current
    ) -> Bool {
        validDestinationSets[sourceId]?.contains(
            PlanMoveDestinationKey(day: calendar.startOfDay(for: date), timebox: timebox)
        ) ?? false
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

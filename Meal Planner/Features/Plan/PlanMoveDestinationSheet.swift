import SwiftUI

struct PlanMoveDestinationSheet: View {
    let planId: UUID
    let sourceId: UUID
    @EnvironmentObject private var vm: PlanViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let plan = vm.plan(id: planId) {
                    let destinations = PlanScheduleMutation.validDestinations(for: sourceId, in: plan)
                    if destinations.isEmpty {
                        ContentUnavailableView("No available timeslots", systemImage: "calendar.badge.exclamationmark")
                    } else {
                        List {
                            ForEach(Array(destinations.enumerated()), id: \.offset) { index, destination in
                                Button {
                                    vm.onIntent(.moveSavedMeal(planId: planId, sourceId: sourceId,
                                                                date: destination.date, timebox: destination.timebox))
                                    dismiss()
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(destination.date.formatted(date: .abbreviated, time: .omitted))
                                            Text(destination.timebox.title).font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(destination.occupied ? "Swap" : "Move here")
                                    }
                                }
                                .accessibilityIdentifier("planMove.destination.\(index)")
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("Plan unavailable", systemImage: "calendar")
                }
            }
            .navigationTitle("Move meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}

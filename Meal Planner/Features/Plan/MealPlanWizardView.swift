//
//  MealPlanWizardView.swift
//  Meal Planner
//
//  5-step meal-planning wizard container (FR §5.2–5.6).
//

import SwiftUI

struct MealPlanWizardView: View {
    @ObservedObject var vm: PlanViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressHeader

                ScrollView {
                    stepContent
                        .padding(16)
                }

                bottomBar
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(vm.state.step.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { vm.onIntent(.closeWizard) }
                }
            }
        }
        .accessibilityIdentifier("planWizard.screen")
    }

    private var progressHeader: some View {
        VStack(spacing: 6) {
            ProgressView(
                value: Double(vm.state.step.rawValue + 1),
                total: Double(PlanWizardStep.allCases.count)
            )
            Text("Step \(vm.state.step.rawValue + 1) of \(PlanWizardStep.allCases.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    @ViewBuilder
    private var stepContent: some View {
        switch vm.state.step {
        case .period: Step1PeriodView(vm: vm)
        case .meals: Step2MealPickerView(vm: vm)
        case .schedule: Step3ScheduleView(vm: vm)
        case .ingredients: Step4IngredientsView(vm: vm)
        case .save: Step5SaveView(vm: vm)
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if let previous = vm.state.step.previous {
                Button {
                    vm.onIntent(.goToStep(previous))
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
            }

            if vm.state.step == .save {
                Button {
                    vm.onIntent(.savePlan)
                } label: {
                    Label("Save Plan", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("planWizard.save")
            } else {
                Button {
                    vm.onIntent(.nextStep)
                } label: {
                    Label("Next", systemImage: "chevron.right")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.state.canAdvance)
                .accessibilityIdentifier("planWizard.next")
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .overlay(alignment: .top) {
            Divider()
        }
    }
}
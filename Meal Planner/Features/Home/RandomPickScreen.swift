//
//  RandomPickScreen.swift
//  Meal Planner
//
//  Created by eric ho on 31/8/2025.
//

import SwiftUI

struct RandomPickScreen: View {
    @ObservedObject var vm: FeatureViewModel

    var body: some View {
        let itemsBinding = Binding<[UIRecipeItem]>(
            get: { vm.state.randomPick.items },
            set: { vm.state.randomPick.items = $0 }
        )

        VStack(spacing: 24) {
            Text("Swipe through 10 fresh picks and keep what you love.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 12)

            Group {
                switch vm.state.randomPick.phase {
                case .loading:
                    RandomPickLoadingView(message: "Finding 10 tasty ideas for you.")
                case .error(let message):
                    RandomPickErrorView(
                        message: message,
                        retryAction: { vm.onIntent(.loadRandomPick) }
                    )
                case .content:
                    CardStackView(items: itemsBinding)
                        .padding(.horizontal, 20)
                case .empty:
                    EmptyStateView(
                        title: "Nothing to pick yet",
                        description: "Tap below and we’ll pull another batch of random recipes."
                    )
                case .idle:
                    RandomPickLoadingView(message: "Warming up the shuffle.")
                }
            }

            if vm.state.randomPick.phase == .empty {
                Button {
                    vm.onIntent(.loadRandomPick)
                } label: {
                    Label("Reload picks", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Random Pick")
        .onAppear {
            vm.onIntent(.loadRandomPick)
        }
    }
}

private struct RandomPickErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            LottieView(animationName: "error-icon")
                .frame(width: 220, height: 220)

            Text("That didn’t go as planned")
                .font(.title3.weight(.semibold))

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: retryAction) {
                Label("Try again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
        }
        .padding(.horizontal, 24)
    }
}

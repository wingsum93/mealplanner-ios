//
//  RandomPickScreen.swift
//  Meal Planner
//
//  Created by eric ho on 31/8/2025.
//

import SwiftUI

struct RandomPickScreen: View {
    @ObservedObject var vm: FeatureViewModel
    @EnvironmentObject var detailVM: DetailViewModel
    @State private var picked: UIRecipeItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Let us surprise you with a random recipe.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)

                if let picked {
                    RecipeHeroCard(item: picked)
                        .onTapGesture { detailVM.onIntent(.setItem(picked)) }
                        .padding(.horizontal, 16)
                } else if vm.state.home.phase == .loading {
                    RecipeHeroCard(item: .sample)
                        .padding(.horizontal, 16)
                        .shimmer(vm.state.home.phase == .loading)
                } else {
                    Text("No random picks available yet.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                }

                Button {
                    if let newPick = pickRandom() {
                        picked = newPick
                    } else {
                        vm.onIntent(.loadHome)
                    }
                } label: {
                    Label("Shuffle pick", systemImage: "shuffle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
        }
        .navigationTitle("Random Pick")
        .onAppear {
            ensureRandomData()
            if picked == nil {
                picked = pickRandom()
            }
        }
        .onChange(of: vm.state.home.randomTen) { _ in
            if picked == nil {
                picked = pickRandom()
            }
        }
    }

    private func ensureRandomData() {
        if vm.state.home.randomTen.isEmpty && vm.state.home.phase != .loading {
            vm.onIntent(.loadHome)
        }
    }

    private func pickRandom() -> UIRecipeItem? {
        vm.state.home.randomTen.randomElement()
    }
}

//
//  HomeScreen.swift
//  Meal Planner
//
//  Created by eric ho on 10/8/2025.
//

import SwiftUI
struct HomeScreen: View {
    @ObservedObject var vm: FeatureViewModel
    let heroNamespace: Namespace.ID
    @EnvironmentObject var detailVM: DetailViewModel

    var body: some View {
        ScrollView {
            searchEntry

            if isInitialHomeLoading {
                SkeletonHomePageView()
            } else {
                homeContent
            }
        }
        .navigationTitle("Recipes")
    }

    private var searchEntry: some View {
        SearchBar(placeholder: "Search recipes…") {
            vm.onIntent(.goToSearch)
        }
        .matchedTransitionSource(id: HeroSearchTransition.searchEntryID, in: heroNamespace)
        .accessibilityIdentifier("home.searchEntry")
        .background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: SearchEntryCenterPreferenceKey.self,
                    value: proxy.frame(in: .named(HeroSearchTransition.coordinateSpace)).center
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var homeContent: some View {
        Group {
            // 1) Featured random recipe
            if let featured = vm.state.home.featured {
                RecipeHeroCard(item: featured)
                    .onTapGesture { detailVM.onIntent(.setItem(featured)) }
                    .padding(.horizontal, 16)
            }

            // 2) Areas horizontal
            SectionHeader("Areas")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.state.home.areas, id: \.self) { area in
                        Button {
                            vm.onIntent(.goToArea(area))
                        } label: {
                            ImageSquareChip(text: area, imageLink: area.getAreaImageURL())
                                .contentShape(Rectangle())  // 明確 hit 區 = 整個 chip
                        }
                        .buttonStyle(.plain)
                    }
                }.padding(.horizontal, 16)
            }

            // 3) Categories horizontal
            SectionHeader("Categories")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.state.home.categories, id: \.self) { cat in
                        Button {
                            vm.onIntent(.goToCategory(cat))
                        } label: {
                            ImageSquareChip(text: cat, imageLink: cat.mealCategoryImageLink)
                                .contentShape(Rectangle())  // 明確 hit 區 = 整個 chip
                        }
                        .buttonStyle(.plain)
                    }
                }.padding(.horizontal, 16)
            }

            // 4) Random 10 horizontal
            SectionHeader("Discover")
            Button {
                vm.onIntent(.goToRandomPick)
            } label: {
                Label("Random Pick", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.state.home.randomTen, id: \.id) { item in
                        RecipeCardSmall(item: item, width: 150)
                            .onTapGesture { detailVM.onIntent(.setItem(item)) }
                    }
                }.padding(.horizontal, 16)
            }
        }
    }

    private var isInitialHomeLoading: Bool {
        vm.state.home.phase == .loading
        && vm.state.home.featured == nil
        && vm.state.home.areas.isEmpty
        && vm.state.home.categories.isEmpty
        && vm.state.home.randomTen.isEmpty
    }
}

private extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

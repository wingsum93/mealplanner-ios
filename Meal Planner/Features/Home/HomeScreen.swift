//
//  HomeScreen.swift
//  Meal Planner
//
//  Created by eric ho on 10/8/2025.
//

import SwiftUI
struct HomeScreen: View {
    @ObservedObject var vm: FeatureViewModel
    let heroNS: Namespace.ID

    var body: some View {
        ScrollView {
            // 1) Featured random recipe
            if let featured = vm.state.home.featured {
                RecipeHeroCard(item: featured, heroNS: heroNS)
                    .onTapGesture { vm.onIntent(.goToDetail(featured.id)) }
                    .padding(.horizontal, 16)
            } else if vm.state.home.phase == .loading {
                SkeletonHeroCard().padding(.horizontal, 16)
            }

            // 2) Areas horizontal
            SectionHeader("Areas")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.state.home.areas, id: \.self) { area in
                        AreaSquareChip(title: area)
                            .onTapGesture { vm.onIntent(.goToArea(area)) }
                    }
                }.padding(.horizontal, 16)
            }

            // 3) Categories horizontal
            SectionHeader("Categories")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.state.home.categories, id: \.self) { cat in
                        CategorySquareChip(title: cat)
                            .onTapGesture { vm.onIntent(.goToCategory(cat)) }
                    }
                }.padding(.horizontal, 16)
            }

            // 4) Random 10 horizontal
            SectionHeader("Discover")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.state.home.randomTen, id: \.id) { item in
                        RecipeCardSmall(item: item, heroNS: heroNS)
                            .onTapGesture { vm.onIntent(.goToDetail(item.id)) }
                    }
                }.padding(.horizontal, 16)
            }

            // 5) Search bar (navigates to Search page)
            SearchBar(placeholder: "Search recipes…") {
                vm.onIntent(.goToSearch)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .overlay {
            if case .loading = vm.state.home.phase {
                SkeletonHomePageView() // your loader
            }
        }
        .navigationTitle("Recipes")
    }
}


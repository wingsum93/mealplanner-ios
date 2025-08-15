//
//  HomeScreen.swift
//  Meal Planner
//
//  Created by eric ho on 10/8/2025.
//

import SwiftUI
struct HomeScreen: View {
    @ObservedObject var vm: FeatureViewModel

    var body: some View {
        ScrollView {
            // 5) Search bar (navigates to Search page)
            SearchBar(placeholder: "Search recipes…") {
                vm.onIntent(.goToSearch)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            // 1) Featured random recipe
            if let featured = vm.state.home.featured {
                RecipeHeroCard(item: featured)
                    .onTapGesture { vm.onIntent(.goToDetail(featured.id)) }
                    .padding(.horizontal, 16)
                    
            } else if vm.state.home.phase == .loading {
                RecipeHeroCard(item: .sample)
                    .padding(.horizontal, 16)
                    .shimmer(vm.state.home.phase == .loading)
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.state.home.randomTen, id: \.id) { item in
                        RecipeCardSmall(item: item)
                            .onTapGesture { vm.onIntent(.goToDetail(item.id)) }
                    }
                }.padding(.horizontal, 16)
            }
        }
        .overlay {
            if case .loading = vm.state.home.phase {
                SkeletonHomePageView() // your loader
            }
        }
        .navigationTitle("Recipes")
    }
}


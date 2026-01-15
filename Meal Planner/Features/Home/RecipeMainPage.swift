//
//  RecipeMainPage.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI

struct RecipeMainPage: View {
    @StateObject var viewModel: FeatureViewModel
    @EnvironmentObject private var detailVM: DetailViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.state.path) {
            HomeScreen(vm: viewModel)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .area(let a):
                        TitleListScreen(
                            title: a,
                            items: $viewModel.state.area.items,
                            onTapItem: {item in
                                print("Tapped id =", item.id)
                                detailVM.onIntent(.setItem(item))
                            }
                        )
                    case .category(let c):
                        TitleListScreen(
                            title: c,
                            items: $viewModel.state.category.items,
                            onTapItem: {item in
                                print("Tapped id =", item.id)
                                detailVM.onIntent(.setItem(item))
                            }
                        )
                    case .search:
                        SearchScreen(
                            query: Binding(
                                get: { viewModel.state.search.query },
                                set: { viewModel.onIntent(.updateQuery($0)) }
                            ),
                            placeholder: "Search recipes…",
                            searchPhase: viewModel.state.search.phase,
                            searchResults: Binding(
                                get: { viewModel.state.search.results },
                                set: { _ in } // ignore external mutation
                            ),
                            onCommit: {
                                viewModel.onIntent(.performSearch)
                            },
                            onClear: {
                                viewModel.onIntent(.updateQuery(""))
                                // vm.onIntent(.resetSearch)
                            },
                            onItemTap: { item in
                                detailVM.onIntent(.setItem(item))
                            }
                        )
                    case .randomPick:
                        RandomPickScreen(vm: viewModel)
                    
                    }
                }
                .task { // first load only once
                    if viewModel.state.home.phase == .idle {
                        viewModel.onIntent(.loadHome)
                    }
                }
        }
    }
    
}

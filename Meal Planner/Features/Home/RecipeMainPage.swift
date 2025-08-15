//
//  RecipeMainPage.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI

struct RecipeMainPage: View {
    @StateObject var viewModel: FeatureViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.state.path) {
            HomeScreen(vm: viewModel)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .area(let a):
                        TitleListScreen(
                            title: a,
                            items: $viewModel.state.area.items,
                            onTapItem: {id in
                                print("Tapped id =", id)
                                viewModel.onIntent(.goToDetail(id))}
                        )
                    case .category(let c):
                        TitleListScreen(
                            title: c,
                            items: $viewModel.state.category.items,
                            onTapItem: {id in viewModel.onIntent(.goToDetail(id))}
                        )
                    case .search:
                        SearchScreen(vm: viewModel)
                    case .detail(let id):
                        DetailScreen(vm: viewModel, id: id)
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


//
//  RecipeMainPage.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI

struct RecipeMainPage: View {
    @StateObject var viewModel: FeatureViewModel
    @Namespace private var heroNS
    
    var body: some View {
        NavigationStack(path: $viewModel.state.path) {
            HomeScreen(vm: viewModel, heroNS: heroNS)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .area(let a):
                        AreaListScreen(vm: viewModel, heroNS: heroNS, area: a)
                    case .category(let c):
                        CategoryListScreen(vm: viewModel, heroNS: heroNS, category: c)
                    case .search:
                        SearchScreen(vm: viewModel)
                    case .detail(let id):
                        DetailScreen(vm: viewModel, heroNS: heroNS, id: id)
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


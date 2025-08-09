//
//  RecipeMainPage.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI

struct RecipeMainPage: View {
    @ObservedObject var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        if viewModel.state.isLoading {
            SkeletonHomePageView()
        } else if let error = viewModel.state.errorMessage {
            VStack(spacing: 16) {
                Text("⚠️ \(error)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                
                Button("Retry") {
                    viewModel.onIntent(.refresh)
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }else {
            LoadedHomePageView(state: viewModel.state)
        }
    }
}


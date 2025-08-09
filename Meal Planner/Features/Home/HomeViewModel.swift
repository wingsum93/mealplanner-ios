//
//  HomeViewModel.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var state = HomeScreenState.initial

    private let repository: RecipeRepository

    init(repository: RecipeRepository) {
        self.repository = repository
    }
    
    func onIntent(_ intent: HomeIntent) {
        switch intent {
        case .load, .refresh:
            loadHomeData()
        default : break
            
        }
        
        
    }

    private func loadHomeData() {
        Task {
            state.isLoading = true
            state.errorMessage = nil
            
            do {
                async let random = repository.getRandomRecipe()
                async let areas = repository.getAllArea()
                async let categories = repository.getAllCategory()
                async let beefRecipes = repository.getBySingleIngredient("Beef")
                
                let (randomResult, areaList, categoryList, beefList) = try await (
                    random, areas, categories, beefRecipes
                )
                
                state.randomRecipe = randomResult.toUI()
                state.areaList = areaList
                state.categoryList = categoryList
                state.beefRecipes = beefList.map { $0.toUI() }
            } catch {
                state.errorMessage = "Failed to load data: \(error.localizedDescription)"
            }
            
            state.isLoading = false
        }
    }
}

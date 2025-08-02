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

    

    private let repository: RecipeRepository

    init(repository: RecipeRepository) {
        self.repository = repository
    }

    func onIntent(_ intent: HomeIntent) {
        
    }

    
}

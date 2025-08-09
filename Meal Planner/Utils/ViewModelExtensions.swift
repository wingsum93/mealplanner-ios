//
//  ViewModelExtensions.swift
//  Meal Planner
//
//  Created by eric ho on 5/8/2025.
//

extension HomeViewModel {
    static var preview: HomeViewModel {
        let vm = HomeViewModel(repository: DummyRecipeRepository())
        vm.state = HomeScreenState(
            isLoading: false,
            errorMessage: nil,
            randomRecipe: .sample,
            areaList: ["American", "British", "Chinese"],
            categoryList: ["Dessert", "Seafood"],
            beefRecipes: [.sample, .sample]
        )
        return vm
    }
}

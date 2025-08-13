//
//  Meal_PlannerApp.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI
import SwiftData

@main
struct RecipeApp: App {
    @State private var di: AppDIContainer
    @StateObject private var homeVM: FeatureViewModel
    @StateObject private var authVM: AuthViewModel
    init() {
        let mc = try! ModelContainer(for: RecipeEntity.self, IngredientEntity.self)
        let container = AppDIContainer(modelContext: ModelContext(mc),
                                       networkClient: AlamofireNetworkClient())
        _di = State(initialValue: container)
        _homeVM = StateObject(wrappedValue: FeatureViewModel(repository: container.recipeRepository))
        _authVM = StateObject(wrappedValue: AuthViewModel(localDataSource: LoginLocalDataSourceImpl())) // your existing one
    }
    
    var body: some Scene {
        WindowGroup {
            RootTabs(homeViewModel: homeVM, authViewModel: authVM)
        }
    }
}

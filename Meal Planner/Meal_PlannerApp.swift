//
//  Meal_PlannerApp.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI
import SwiftData

@main
struct Meal_PlannerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            RecipeEntity.self,
            IngredientEntity.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        
        WindowGroup {
            let di = AppDIContainer(
                modelContext: ModelContext(sharedModelContainer),
                networkClient: AlamofireNetworkClient()
            )
            HomeScreen(homeViewModel: di.makeHomeViewModel())
                .modelContainer(sharedModelContainer)
        }
    }
}

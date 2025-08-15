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
                .environment(\.openURL, OpenURLAction { url in
                    // 自訂行為：統一加 UTM、做 analytics、block 黑名單等
                    print("Opening: \(url)")
                    return .systemAction  // 交返系統處理
                    // return .handled    // 你已自行處理
                    // return .discarded  // 忽略
                })
        }
    }
}

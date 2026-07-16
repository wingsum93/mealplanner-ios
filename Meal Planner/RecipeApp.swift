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
    @StateObject private var appRouter: AppRouter
    @StateObject private var homeVM: FeatureViewModel
    @StateObject private var detailVM: DetailViewModel
    @StateObject private var favVM: FavouriteViewModel
    @StateObject private var settingsVM: SettingsViewModel
    init() {
        let isUITestingInMemoryStore = CommandLine.arguments.contains("-uiTestingInMemoryStore")
        let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: isUITestingInMemoryStore)
        let mc = try! ModelContainer(
            for: RecipeEntity.self,
            IngredientEntity.self,
            configurations: modelConfiguration
        )
        let container = AppDIContainer(modelContext: ModelContext(mc),
                                       networkClient: AlamofireNetworkClient())
        _di = State(initialValue: container)
        _appRouter = StateObject(wrappedValue: AppRouter())
        _homeVM = StateObject(wrappedValue: FeatureViewModel(repository: container.recipeRepository))
        _detailVM = StateObject(wrappedValue: DetailViewModel(repository: container.recipeRepository))
        let favouriteViewModel = FavouriteViewModel(repository: container.recipeRepository)
        _favVM = StateObject(wrappedValue: favouriteViewModel)
        _settingsVM = StateObject(
            wrappedValue: container.makeSettingsViewModel {
                favouriteViewModel.onIntent(.loadFavorites)
            }
        )
    }
    
    var body: some Scene {
        WindowGroup {
            RootTabs(
                homeViewModel: homeVM,
                settingsViewModel: settingsVM
            )
                .environment(\.openURL, OpenURLAction { url in
                    // 自訂行為：統一加 UTM、做 analytics、block 黑名單等
                    print("Opening: \(url)")
                    return .systemAction  // 交返系統處理
                    // return .handled    // 你已自行處理
                    // return .discarded  // 忽略
                })
                .environmentObject(appRouter)
                .environmentObject(detailVM)
                .environmentObject(favVM)
        }
    }
}

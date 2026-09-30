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
    @StateObject private var myListVM: MyListViewModel
    @StateObject private var planVM: PlanViewModel
    @StateObject private var settingsVM: SettingsViewModel
    init() {
        ImageCacheConfig.configure()

        let isUITestingInMemoryStore = CommandLine.arguments.contains("-uiTestingInMemoryStore")
        let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: isUITestingInMemoryStore)
        let mc = try! ModelContainer(
            for: RecipeEntity.self,
            IngredientEntity.self,
            RecipeListEntry.self,
            ProcurementPlanEntity.self,
            PlanSlotEntity.self,
            PlanIngredientEntity.self,
            configurations: modelConfiguration
        )
        let container = AppDIContainer(modelContext: ModelContext(mc),
                                       networkClient: AlamofireNetworkClient())
        if isUITestingInMemoryStore && CommandLine.arguments.contains("-uiTestingFX002Fixture") {
            try? container.planRepository.savePlan(Self.fx002Fixture())
        }
        _di = State(initialValue: container)
        _appRouter = StateObject(wrappedValue: AppRouter())
        let homeViewModel = FeatureViewModel(repository: container.recipeRepository)
        let detailViewModel = DetailViewModel(repository: container.recipeRepository)
        detailViewModel.onFavoriteChanged = { item in
            homeViewModel.onIntent(.updateSearchFavorite(id: item.id, isFavorite: item.isFavorite))
        }
        _homeVM = StateObject(wrappedValue: homeViewModel)
        _detailVM = StateObject(wrappedValue: detailViewModel)
        let myListViewModel = MyListViewModel(repository: container.recipeRepository)
        _myListVM = StateObject(wrappedValue: myListViewModel)
        _planVM = StateObject(wrappedValue: container.makePlanViewModel())
        _settingsVM = StateObject(
            wrappedValue: container.makeSettingsViewModel {
                myListViewModel.onIntent(.loadList(.favourite))
            }
        )
    }

    private static func fx002Fixture() -> ProcurementPlan {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? tomorrow
        return ProcurementPlan(
            id: UUID(), name: "FX-002 Sample Plan", startDate: today,
            endDate: max(nextMonth, tomorrow), createdAt: today, adjustCount: 0,
            slots: [
                PlanSlot(date: today, timebox: .lunch, mealId: 1001, displayOrder: 0),
                PlanSlot(date: tomorrow, timebox: .dinner, mealId: 1002, displayOrder: 1)
            ],
            ingredients: [
                PlanIngredient(name: "Beef", quantityText: "200 g", unit: "g", category: .meat, occurrenceCount: 1),
                PlanIngredient(name: "Carrot", quantityText: "2", unit: "", category: .vegetable, occurrenceCount: 1)
            ],
            selectedTimeboxes: [.lunch, .dinner],
            mealSnapshots: [
                PlanMealSnapshot(id: 1001, title: "Beef Bowl", ingredients: [PlanMealIngredient(name: "Beef", measure: "200 g")]),
                PlanMealSnapshot(id: 1002, title: "Carrot Soup", ingredients: [PlanMealIngredient(name: "Carrot", measure: "2")])
            ]
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
                .environmentObject(myListVM)
                .environmentObject(planVM)
        }
    }
}

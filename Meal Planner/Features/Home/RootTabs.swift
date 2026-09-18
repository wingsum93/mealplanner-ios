//
//  Home.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI
import SwiftData

struct RootTabs: View {
    @EnvironmentObject private var appRouter: AppRouter
    @EnvironmentObject private var detailVM: DetailViewModel
    @StateObject private var settingsViewModel: SettingsViewModel
    @StateObject private var vm:FeatureViewModel
    @State private var recipeDetailDetent: PresentationDetent = .medium
    @Namespace private var heroNS  // shared namespace
    
    init(
        homeViewModel: FeatureViewModel,
        settingsViewModel: SettingsViewModel
    ) {
        _settingsViewModel = StateObject(wrappedValue: settingsViewModel)
        _vm = StateObject(wrappedValue:homeViewModel)
    }
    
    var body: some View{
        
        TabView(selection: $appRouter.selectedTab) {
            RecipeMainPage(viewModel: vm, heroNamespace: heroNS)
                .tabItem{Label("Home", systemImage: "house")}
                .tag(AppTab.home)
            
            NavigationStack {
                FavouriteScreen()
            }
                .tabItem{
                    Label("Favourite", systemImage: "star.fill")
                }
                .tag(AppTab.favourite)
            ProfileScreen(
                settingsViewModel: settingsViewModel
            )
            .tabItem{
                Label("Profile", systemImage: "person.circle")
            }
            .tag(AppTab.profile)
            
        }
        .onChange(of: appRouter.activeSheet) { sheet in
            seedRecipeDetailDetent(for: sheet)
        }
        .sheet(item: $appRouter.activeSheet, onDismiss: {
            detailVM.onIntent(.dismiss)
        }) { sheet in
            switch sheet {
            case .recipeDetail(let item):
                DetailSheetView(
                    item: item,
                    vm: detailVM,
                    onTapIngredient: { ingredient in
                        vm.onIntent(.loadIngredientMeals(ingredient))
                        appRouter.showIngredientMeals(ingredient)
                    }
                )
                    .presentationDetents([.medium, .large], selection: $recipeDetailDetent)
                    .presentationDragIndicator(.visible)
                    .background(Color(.systemGray6))
                    .pagePresentationSizingIfAvailable()
                    .onAppear {
                        seedRecipeDetailDetent(for: sheet)
                    }
            }
        }
        .fullScreenCover(item: $appRouter.activeFullScreenCover) { cover in
            switch cover {
            case .randomPick:
                NavigationStack {
                    RandomPickScreen(vm: vm)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    appRouter.dismissFullScreenCover()
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.headline)
                                }
                                .accessibilityLabel("Close")
                            }
                        }
                }
            }
        }
    }
    
    private func seedRecipeDetailDetent(for sheet: AppSheet?) {
        guard case .recipeDetail = sheet else { return }
        recipeDetailDetent = settingsViewModel.state.showLargeMealPage ? .large : .medium
    }
}

private extension View {
    @ViewBuilder
    func pagePresentationSizingIfAvailable() -> some View {
        if #available(iOS 18.0, *) {
            presentationSizing(.page)
        } else {
            self
        }
    }
}

//#Preview {
//    HomeScreen(homeViewModel: .preview)
//        .modelContainer(for: Item.self, inMemory: true)
//    
//}

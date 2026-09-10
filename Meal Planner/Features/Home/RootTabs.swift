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
    @Namespace private var heroNS  // shared namespace
    
    init(
        homeViewModel: FeatureViewModel,
        settingsViewModel: SettingsViewModel
    ) {
        _settingsViewModel = StateObject(wrappedValue: settingsViewModel)
        _vm = StateObject(wrappedValue:homeViewModel)
    }
    
    var body: some View{
        
        TabView{
            RecipeMainPage(viewModel: vm, heroNamespace: heroNS)
                .tabItem{Label("Home", systemImage: "house")}
            
            NavigationStack {
                FavouriteScreen()
            }
                .tabItem{
                    Label("Favourite", systemImage: "star.fill")
                }
            ProfileScreen(
                settingsViewModel: settingsViewModel
            )
            .tabItem{
                Label("Profile", systemImage: "person.circle")
            }
            
        }
        .sheet(item: $appRouter.activeSheet, onDismiss: {
            detailVM.onIntent(.dismiss)
        }) { sheet in
            switch sheet {
            case .recipeDetail(let item):
                DetailSheetView(item: item, vm: detailVM)
                    .presentationDetents([ .large,.medium])
                    .presentationDragIndicator(.visible)
                    .background(Color(.systemGray6))
                    .presentationSizing(.page)
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
    
}

//#Preview {
//    HomeScreen(homeViewModel: .preview)
//        .modelContainer(for: Item.self, inMemory: true)
//    
//}

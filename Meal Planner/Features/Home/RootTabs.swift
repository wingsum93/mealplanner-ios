//
//  Home.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI
import SwiftData

struct RootTabs: View {
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
            
            FavouriteScreen()
                .tabItem{
                    Label("Favourite", systemImage: "star.fill")
                }
            ProfileScreen(
                settingsViewModel: settingsViewModel
            )
            .tabItem{
                Label("Profile", systemImage: "person.circle")
            }
            
        }.sheet(isPresented: Binding(get: {detailVM.state.isPresented }, set: { newValue in
            if(newValue == false){
                detailVM.onIntent(.dismiss)
            }
        })) {
            DetailSheetView(vm: detailVM)
            // Optional detents if you like:
                .presentationDetents([ .large,.medium])
                .presentationDragIndicator(.visible)
                .background(Color(.systemGray6))
                .presentationSizing(.page)
        }
    }
    
}

//#Preview {
//    HomeScreen(homeViewModel: .preview)
//        .modelContainer(for: Item.self, inMemory: true)
//    
//}

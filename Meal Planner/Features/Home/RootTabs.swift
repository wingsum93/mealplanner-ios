//
//  Home.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI
import SwiftData

struct RootTabs: View {
    @State private var showLoginDialog = false
    @EnvironmentObject private var detailVM: DetailViewModel
    @StateObject private var authViewModel:AuthViewModel
    @StateObject private var settingsViewModel: SettingsViewModel
    @StateObject private var vm:FeatureViewModel
    @Namespace private var heroNS  // shared namespace
    
    init(
        homeViewModel: FeatureViewModel,
        authViewModel: AuthViewModel,
        settingsViewModel: SettingsViewModel
    ) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
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
                authViewModel: authViewModel,
                settingsViewModel: settingsViewModel
            ) {
                showLoginDialog = true
            }
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

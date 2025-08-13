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
    @StateObject private var authViewModel:AuthViewModel
    @StateObject private var vm:FeatureViewModel
    @Namespace private var heroNS  // shared namespace
    
    init( homeViewModel:FeatureViewModel,authViewModel:AuthViewModel) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
        _vm = StateObject(wrappedValue:homeViewModel)
    }
    
    var body: some View{
        
        TabView{
            RecipeMainPage(viewModel: vm)
                .tabItem{Label("Home", systemImage: "house")}
            
            FavouriteScreen()
                .tabItem{
                    Label("Favourite", systemImage: "star.fill")
                }
            ProfileScreen(authViewModel: authViewModel){
                showLoginDialog = true
            }
                .tabItem{
                    Label("Profile", systemImage: "person.circle")
                }
            SelfEsteem(click: { showLoginDialog = !showLoginDialog})
                .tabItem{
                    Label("Me", systemImage: "star.fill")
                }
            
        }.sheet(isPresented: $showLoginDialog) {
            LoginBottomSheet(authViewModel: authViewModel)
        }
    }
    
}

//#Preview {
//    HomeScreen(homeViewModel: .preview)
//        .modelContainer(for: Item.self, inMemory: true)
//    
//}

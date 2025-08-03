//
//  Home.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI
import SwiftData

struct HomeScreen: View {
    @State private var showLoginDialog = false
    @StateObject private var authViewModel:AuthViewModel
    
    init() {
        _authViewModel = StateObject(wrappedValue: AuthViewModel(localDataSource: LoginLocalDataSourceImpl()))
        
    }
    
    var body: some View{
        
        TabView{
            RecipeMainPage()
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

#Preview {
    HomeScreen()
        .modelContainer(for: Item.self, inMemory: true)
}

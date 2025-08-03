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

    
    var body: some View{
        
        TabView{
            RecipeMainPage()
                .tabItem{Label("Home", systemImage: "house")}
            
            FavouriteScreen()
                .tabItem{
                    Label("Favourite", systemImage: "star.fill")
                }
            SelfEsteem(click: { showLoginDialog = !showLoginDialog})
                .tabItem{
                    Label("Me", systemImage: "star.fill")
                }
            
        }.sheet(isPresented: $showLoginDialog) {
            LoginBottomSheet(
                onGuestLogin: { print("Guest login") }
            )
        }
    }
    
}

#Preview {
    HomeScreen()
        .modelContainer(for: Item.self, inMemory: true)
}

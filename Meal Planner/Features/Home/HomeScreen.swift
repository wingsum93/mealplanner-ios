//
//  Home.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI
import SwiftData

struct HomeScreen: View {
  
    
    var body: some View{
        Text("Eric is the best")
            .bold()
            .font(.largeTitle)
    }
    
}

#Preview {
    HomeScreen()
        .modelContainer(for: Item.self, inMemory: true)
}

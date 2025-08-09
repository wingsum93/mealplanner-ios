//
//  LoadedHomePageView.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//
import SwiftUI

struct LoadedHomePageView:View{
    
    let state: HomeScreenState
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Feature: Random Recipe
                if let recipe = state.randomRecipe {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Featured Dish")
                            .font(.headline)
                        RecipeCardLarge(item: recipe)
                    }
                }
                
                // Section: Beef Recipes
                VStack(alignment: .leading, spacing: 12) {
                    Text("Beef Recipes")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(state.beefRecipes) { item in
                                RecipeCardSmall(item: item)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Section: Categories
                if !state.categoryList.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Categories")
                            .font(.headline)
                        
                        WrapHStack(items: state.categoryList) { category in
                            TagChip(text: category)
                        }
                    }
                }
                
                // Section: Areas
                if !state.areaList.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cuisine Areas")
                            .font(.headline)
                        
                        WrapHStack(items: state.areaList) { area in
                            TagChip(text: area)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

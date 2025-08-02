//
//  CategoryList.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI

struct CategoryList: View {
    @State private var selected: String = "Beef"
    let categories = ["Beef", "Chicken", "Dessert", "Seafood", "Vegan"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryChip(
                        label: category,
                        selected: category == selected,
                        onTap: {
                            selected = category
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview(){
    CategoryList()
}

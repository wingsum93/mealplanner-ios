//
//  CategoryList.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI

struct CategoryList: View {
    @State private var selected: String = "Beef"
        let items = [
            ("Beef", "https://www.themealdb.com/images/category/beef.png"),
            ("Dessert", "https://www.themealdb.com/images/category/dessert.png"),
            ("Chicken", "https://www.themealdb.com/images/category/chicken.png")
        ]
    

    var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items, id: \.0) { (label, url) in
                        CategoryChip(
                            label: label,
                            imageUrl: url,
                            selected: label == selected,
                            onTap: { selected = label }
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

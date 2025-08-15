//
//  AreaListScreen.swift
//  Meal Planner
//
//  Created by eric ho on 13/8/2025.
//
import SwiftUI
import Kingfisher

// Use for area list and category list
struct TitleListScreen: View {
    let title: String
    @Binding var items: [UIRecipeItem]           // 你的模型類型
    let onTapItem:(String)->Void
    
    init(title:String,
         items: Binding<[UIRecipeItem]>,
         onTapItem: @escaping(String)->Void = {_ in }){
        self.title = title
        self._items = items      // ✅ 注意用底線
        self.onTapItem = onTapItem
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items, id: \.id) { item in
                    Button {
                        onTapItem(item.id)
                    } label: {
                        RecipeCardSmall(item: item)
                            .contentShape(Rectangle()) // 放大可點擊區
                    }
                    .buttonStyle(.plain)           // 不要系統的藍色高亮
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationTitle(title)
    }
}


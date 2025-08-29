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
    let onTapItem:(UIRecipeItem)->Void
    
    let hPadding: CGFloat = 16
    let interItemSpacing: CGFloat = 12
    
    // ❗️注意：用 UIScreen 係固定寬度，旋轉/多工視窗唔會更新
    private let screenW = UIScreen.main.bounds.width
    private var cellWidth: CGFloat {
        (screenW - hPadding * 2 - interItemSpacing) / 2
    }
    
    init(title:String,
         items: Binding<[UIRecipeItem]>,
         onTapItem: @escaping(UIRecipeItem)->Void = {_ in }){
        self.title = title
        self._items = items      // ✅ 注意用底線
        self.onTapItem = onTapItem
    }
    
    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: interItemSpacing),
            GridItem(.flexible(), spacing: interItemSpacing)
        ]
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: interItemSpacing) {
                ForEach(items, id: \.id) { item in
                    RecipeCardSmall(item: item, width: cellWidth)
                        .onTapGesture { onTapItem(item) }
                }
            }
            .padding(.horizontal, hPadding)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationTitle(title)
    }
}


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
    let items: [UIRecipeItem]
    let onTapItem:(UIRecipeItem)->Void
    
    let hPadding: CGFloat = 16
    let interItemSpacing: CGFloat = 12
    private let minimumCellWidth: CGFloat = 150
    
    init(title:String,
         items: [UIRecipeItem],
         onTapItem: @escaping(UIRecipeItem)->Void = {_ in }){
        self.title = title
        self.items = items
        self.onTapItem = onTapItem
    }
    
    private func gridMetrics(for containerWidth: CGFloat) -> (columns: [GridItem], cellWidth: CGFloat) {
        let availableWidth = max(containerWidth - hPadding * 2, minimumCellWidth)
        let count = max(Int((availableWidth + interItemSpacing) / (minimumCellWidth + interItemSpacing)), 2)
        let cellWidth = (availableWidth - CGFloat(count - 1) * interItemSpacing) / CGFloat(count)
        let columns = Array(
            repeating: GridItem(.fixed(cellWidth), spacing: interItemSpacing),
            count: count
        )
        return (columns, cellWidth)
    }
    
    var body: some View {
        GeometryReader { proxy in
            let metrics = gridMetrics(for: proxy.size.width)

            ScrollView {
                LazyVGrid(columns: metrics.columns, spacing: interItemSpacing) {
                    ForEach(items, id: \.id) { item in
                        RecipeCardSmall(item: item, width: metrics.cellWidth)
                            .onTapGesture { onTapItem(item) }
                    }
                }
                .padding(.horizontal, hPadding)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(title)
    }
}

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
    let phase: LoadPhase
    let onTapItem:(UIRecipeItem)->Void
    
    let hPadding: CGFloat = 16
    let interItemSpacing: CGFloat = 12
    private let minimumCellWidth: CGFloat = 150
    
    init(title:String,
         items: [UIRecipeItem],
         phase: LoadPhase = .content,
         onTapItem: @escaping(UIRecipeItem)->Void = {_ in }){
        self.title = title
        self.items = items
        self.phase = phase
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
                if isInitialLoading {
                    TitleListSkeletonGrid(
                        columns: metrics.columns,
                        cellWidth: metrics.cellWidth,
                        spacing: interItemSpacing,
                        hPadding: hPadding
                    )
                } else {
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
        }
        .navigationTitle(title)
    }

    private var isInitialLoading: Bool {
        phase == .loading && items.isEmpty
    }
}

private struct TitleListSkeletonGrid: View {
    let columns: [GridItem]
    let cellWidth: CGFloat
    let spacing: CGFloat
    let hPadding: CGFloat

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(0..<8, id: \.self) { _ in
                SkeletonTitleListRecipeCard(width: cellWidth)
            }
        }
        .padding(.horizontal, hPadding)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .accessibilityHidden(true)
    }
}

private struct SkeletonTitleListRecipeCard: View {
    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            SkeletonRoundedRectangle(cornerRadius: 12)
                .frame(width: width, height: width)

            SkeletonRoundedRectangle(cornerRadius: 5)
                .frame(width: width * 0.78, height: 14)

            HStack(spacing: 6) {
                SkeletonRoundedRectangle(cornerRadius: 8)
                    .frame(width: width * 0.34, height: 18)

                SkeletonRoundedRectangle(cornerRadius: 8)
                    .frame(width: width * 0.28, height: 18)
            }
        }
        .frame(width: width, height: width + 40, alignment: .topLeading)
        .padding(.bottom, 8)
    }
}

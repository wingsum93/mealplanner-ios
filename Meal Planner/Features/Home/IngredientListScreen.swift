//
//  IngredientListScreen.swift
//  Meal Planner
//
//  Created by eric ho on 16/9/2026.
//

import SwiftUI

struct IngredientListScreen: View {
    let title: String
    let items: [Ingredient]
    let phase: LoadPhase
    let onTapIngredient: (Ingredient) -> Void

    let hPadding: CGFloat = 16
    let interItemSpacing: CGFloat = 12
    private let minimumCellWidth: CGFloat = 88

    init(
        title: String = "Ingredients",
        items: [Ingredient],
        phase: LoadPhase = .content,
        onTapIngredient: @escaping (Ingredient) -> Void = { _ in }
    ) {
        self.title = title
        self.items = items
        self.phase = phase
        self.onTapIngredient = onTapIngredient
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
                    IngredientListSkeletonGrid(
                        columns: metrics.columns,
                        cellWidth: metrics.cellWidth,
                        spacing: interItemSpacing,
                        hPadding: hPadding
                    )
                } else {
                    LazyVGrid(columns: metrics.columns, spacing: interItemSpacing) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            IngredientSquareCard(name: item.name, size: metrics.cellWidth)
                                .accessibilityIdentifier("ingredientList.card.\(index)")
                                .onTapGesture { onTapIngredient(item) }
                        }
                    }
                    .accessibilityIdentifier("ingredientList.grid")
                    .padding(.horizontal, hPadding)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle(title)
        .accessibilityIdentifier("ingredientList.screen")
    }

    private var isInitialLoading: Bool {
        phase == .loading && items.isEmpty
    }
}

private struct IngredientListSkeletonGrid: View {
    let columns: [GridItem]
    let cellWidth: CGFloat
    let spacing: CGFloat
    let hPadding: CGFloat

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(0..<12, id: \.self) { _ in
                SkeletonIngredientCard(width: cellWidth)
            }
        }
        .padding(.horizontal, hPadding)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .accessibilityHidden(true)
    }
}

private struct SkeletonIngredientCard: View {
    let width: CGFloat

    var body: some View {
        VStack(spacing: 6) {
            SkeletonRoundedRectangle(cornerRadius: 10)
                .frame(width: width, height: width)

            SkeletonRoundedRectangle(cornerRadius: 5)
                .frame(width: width * 0.7, height: 12)
        }
        .frame(width: width)
    }
}

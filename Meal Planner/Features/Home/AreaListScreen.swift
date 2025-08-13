//
//  AreaListScreen.swift
//  Meal Planner
//
//  Created by eric ho on 13/8/2025.
//
import SwiftUI

struct AreaListScreen: View {
    @ObservedObject var vm: FeatureViewModel
    let heroNS: Namespace.ID
    let area: String

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(vm.state.area.items, id: \.id) { item in
                    AreaGridItemView(item: item, heroNS: heroNS)
                        .onTapGesture { vm.onIntent(.goToDetail(item.id)) }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationTitle(area)
    }
}

// MARK: - Grid Item (square image background + 0.3 overlay + centered text)
private struct AreaGridItemView: View {
    let item: UIRecipeItem
    let heroNS: Namespace.ID

    var body: some View {
        ZStack {
            // Background image (square)
            AsyncImage(url: item.thumbURL) { phase in
                switch phase {
                case .empty:
                    Rectangle().fill(Color(.systemGray5))
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(Image(systemName: "photo").foregroundColor(.secondary))
                @unknown default:
                    Rectangle().fill(Color(.systemGray5))
                }
            }
            .matchedGeometryEffect(id: item.id, in: heroNS)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                // 0.3 alpha grey layer
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.black.opacity(0.3))
            )

            // Centered text
            Text(item.name)
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(radius: 4)
                .padding(.horizontal, 10)
        }
        // Make it square
        .aspectRatio(1, contentMode: .fit)
        .contentShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(item.name + (item.area.map { ", \($0)" } ?? "")))
    }
}


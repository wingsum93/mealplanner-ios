//
//  CategoryListScreen.swift
//  Meal Planner
//
//  Created by eric ho on 13/8/2025.
//
import SwiftUI

struct CategoryListScreen: View {
    @ObservedObject var vm: FeatureViewModel
    let heroNS: Namespace.ID
    let category: String

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(vm.state.category.items, id: \.id) { item in
                    CategoryGridItemView(item: item, heroNS: heroNS)
                        .onTapGesture { vm.onIntent(.goToDetail(item.id)) }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationTitle(category)
        .toolbar {
            if !vm.state.category.items.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(vm.state.category.items.count)")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                        .monospacedDigit()
                        .accessibilityLabel("\(vm.state.category.items.count) recipes")
                }
            }
        }
        // If you sometimes arrive without data loaded, uncomment:
        // .task {
        //     if vm.state.category.items.isEmpty {
        //         vm.onIntent(.loadCategory(category))
        //     }
        // }
        // .refreshable { vm.onIntent(.loadCategory(category)) }
    }
}

// MARK: - Grid Item (square image background + 0.3 overlay + centered text)
private struct CategoryGridItemView: View {
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
        .aspectRatio(1, contentMode: .fit) // square tile
        .contentShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(item.name + (item.area.map { ", \($0)" } ?? "")))
    }
}


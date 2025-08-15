//
//  RecipeRow.swift
//  Meal Planner
//
//  Created by eric ho on 10/8/2025.
//
import SwiftUI
import Kingfisher

struct SearchRecipeRow: View {
    let item: UIRecipeItem
    var showFavorite: Bool = false
    var onFavoriteToggle: ((Bool) -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            KFImage(item.thumbURL)
                .placeholder {
                    Color.gray // 載入中顯示
                }
                .resizable()
                .scaledToFit()

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(2)

                if let area = item.area, !area.isEmpty {
                    Text(area)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Optional favourite button
            if showFavorite, let onFavoriteToggle = onFavoriteToggle {
                Button {
                    onFavoriteToggle(!item.isFavorite)
                } label: {
                    Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(item.isFavorite ? .red : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
}

//
//  RecipeRow.swift
//  Meal Planner
//
//  Created by eric ho on 10/8/2025.
//
import SwiftUI

struct RecipeRow: View {
    let item: UIRecipeItem
    var showFavorite: Bool = false
    var onFavoriteToggle: ((Bool) -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            AsyncImage(url: item.thumbURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(8)
                case .failure:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                @unknown default:
                    EmptyView()
                }
            }

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

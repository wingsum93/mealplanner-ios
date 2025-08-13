//
//  RecipeHeroCard.swift
//  Meal Planner
//
//  Created by eric ho on 14/8/2025.
//
import SwiftUI

struct RecipeHeroCard: View {
    let item: UIRecipeItem
    let heroNS: Namespace.ID

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image
            AsyncImage(url: item.thumbURL) { phase in
                switch phase {
                case .empty:
                    Rectangle().fill(Color(.systemGray5))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                @unknown default:
                    Rectangle().fill(Color(.systemGray5))
                }
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .clipped()
            .cornerRadius(14)
            .matchedGeometryEffect(id: item.id, in: heroNS)

            // Overlay gradient
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Bottom text
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(radius: 4)

                if let area = item.area, !area.isEmpty {
                    Text(area)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                        .shadow(radius: 2)
                }
            }
            .padding(12)
        }
        .frame(height: 200)
        .contentShape(RoundedRectangle(cornerRadius: 14))
    }
}


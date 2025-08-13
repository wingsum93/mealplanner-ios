//
//  RecipeCardLarge.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//
import SwiftUI

struct RecipeCardLarge: View {
    let item: UIRecipeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AsyncImage(url: item.thumbURL) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(item.name)
                .font(.subheadline)
                .lineLimit(1)

            HStack(spacing: 8) {
                Label("20 mins", systemImage: "clock")
                    .font(.caption2)
                Label("5 stars", systemImage: "star.fill")
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
        }
    }
}


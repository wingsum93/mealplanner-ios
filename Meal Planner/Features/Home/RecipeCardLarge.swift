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
            AsyncImage(url: URL(string: item.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(item.title)
                .font(.subheadline)
                .lineLimit(1)

            HStack(spacing: 8) {
                Label(item.duration, systemImage: "clock")
                    .font(.caption2)
                Label("\(item.rating)", systemImage: "star.fill")
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
        }
    }
}


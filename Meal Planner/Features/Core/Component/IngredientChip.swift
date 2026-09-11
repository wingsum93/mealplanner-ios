//
//  IngredientChip.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI

struct IngredientChip: View {
    let name: String
    let dose: String
    let imageUrl: String

    var body: some View {
        HStack(spacing: 9) {
            ingredientImage

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                Text(dose)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(
            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.secondary.opacity(0.16),
                            Color.primary.opacity(0.09),
                            Color(.systemBackground).opacity(0.82)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.primary.opacity(0.22),
                            Color.secondary.opacity(0.26)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.primary.opacity(0.08), radius: 5, x: 0, y: 3)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(name), \(dose)"))
    }

    private var ingredientImage: some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            Group {
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    Image(systemName: "leaf.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.primary.opacity(0.8))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ProgressView()
                        .controlSize(.mini)
                }
            }
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(Color(.systemBackground).opacity(0.9))
            )
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
            )
        }
    }
}

#Preview {
    let items: [(name: String, dose: String, imageUrl: String)] = [
        ("Onion", "2 slices", "https://www.themealdb.com/images/ingredients/Onion.png"),
        ("Beef", "300g", "https://www.themealdb.com/images/ingredients/Beef.png"),
        ("Tomato", "1 whole", "https://www.themealdb.com/images/ingredients/Tomato.png")
    ]

    ScrollView(.horizontal, showsIndicators: false) {
        VStack(spacing: 10) {
            ForEach(items, id: \.name) { item in
                IngredientChip(name: item.name, dose: item.dose, imageUrl: item.imageUrl)
            }
        }
        .padding(.horizontal)
    }
}

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
        HStack(spacing: 8) {
            AsyncImage(url: URL(string: imageUrl)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                } else if phase.error != nil {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "xmark")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                } else {
                    ProgressView()
                        .frame(width: 24, height: 24)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.caption)
                    .foregroundColor(.primary)
                Text(dose)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
        )
        .overlay(
            Capsule()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    let items: [(name: String, dose: String, imageUrl: String)] = [
            ("Onion", "2 slices", "https://www.themealdb.com/images/ingredients/Onion.png"),
            ("Beef", "300g", "https://www.themealdb.com/images/ingredients/Beef.png"),
            ("Tomato", "1 whole", "https://www.themealdb.com/images/ingredients/Tomato.png")
        ]

        
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
            ForEach(items, id: \.name) { item in
                IngredientChip(name: item.name, dose: item.dose, imageUrl: item.imageUrl)
            }
        }
        .padding(.horizontal)
    }
    
}

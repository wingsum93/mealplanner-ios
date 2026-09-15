//
//  IngredientSquareCard.swift
//  Meal Planner
//
//  Created by eric ho on 16/9/2026.
//

import SwiftUI
import Kingfisher

struct IngredientSquareCard: View {
    let name: String
    var size: CGFloat = 88

    var body: some View {
        VStack(spacing: 6) {
            KFImage(imageURL)
                .placeholder {
                    Color.gray.opacity(0.2)
                }
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .frame(width: size)
        }
        .frame(width: size)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(name))
    }

    private var imageURL: URL? {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        return URL(string: "https://www.themealdb.com/images/ingredients/\(encoded)-small.png")
    }
}

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
            ForEach(["Chicken", "Onion", "Tomato", "Garlic", "Beef"], id: \.self) { name in
                IngredientSquareCard(name: name)
            }
        }
        .padding(.horizontal)
    }
}
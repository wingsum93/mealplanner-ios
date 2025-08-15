//
//  RecipeCardSmall.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//
import SwiftUI
import Kingfisher

struct RecipeCardSmall: View {
    let item: UIRecipeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            KFImage(item.thumbURL)
                .placeholder {
                    Color.gray.allowsHitTesting(false) // 載入中顯示
                }
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(item.name)
                .font(.subheadline)
                .lineLimit(1)

            TagChipsRow(tags: item.ingredients,availableWidth: 120)
            .foregroundColor(.secondary)
        }
        .frame(width: 120)
    }
}
#Preview {
    RecipeCardSmall(item: .sample)
}

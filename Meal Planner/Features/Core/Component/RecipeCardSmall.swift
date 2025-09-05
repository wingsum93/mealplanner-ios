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
    var width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            KFImage(item.thumbURL)
                .placeholder {
                    Color.gray.allowsHitTesting(false) // 載入中顯示
                }
                .resizable()
                .scaledToFill()
                .frame(width: width, height: width) // square image
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(item.name)
                .font(.subheadline)
                .lineLimit(1)
            let sortedTags = item.ingredients.sorted { $0.count < $1.count }
            TagChipsRow(
                tags: sortedTags,
                availableWidth: width,
                spacing: 6
            )
            .foregroundColor(.secondary)
        }
        .frame(width: width,height: width + 40, alignment: .leading)
        .padding(.bottom,8)
    }
}
#Preview {
    RecipeCardSmall(item: .sample,width: .infinity)
}

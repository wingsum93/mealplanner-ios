//
//  RecipeCardSmall.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//
import SwiftUI
struct RecipeCardSmall: View {
    let item: UIRecipeItem
    let heroNS: Namespace.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AsyncImage(url: item.thumbURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 120, height: 100)
            .matchedGeometryEffect(id: item.id, in: heroNS)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(item.name)
                .font(.subheadline)
                .lineLimit(1)

            HStack(spacing: 8) {
                Label("20 mins", systemImage: "clock")
                    .font(.caption2)
                Label("\("5 stars")", systemImage: "star.fill")
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
        }
        .frame(width: 120)
    }
}
//#Preview {
//    RecipeCardSmall(item: .sample)
//}

//
//  RecipeItemChip.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI

struct RecipeItemChip: View {
    let text: String
    let imageUrl: String
    let selected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(text)
                    .font(.caption)
                    .fontWeight(selected ? .semibold : .regular)
                    .foregroundColor(selected ? .accentColor : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                AsyncImage(url: URL(string: imageUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else if phase.error != nil {
                        Color.red
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        ProgressView()
                            .frame(width: 48, height: 48)
                    }
                }
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selected ? Color.accentColor.opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(selected ? 1.05 : 1.0)
            .shadow(color: selected ? .black.opacity(0.15) : .clear, radius: 4, x: 0, y: 2)
            .animation(.easeInOut(duration: 0.2), value: selected)
        }
        .buttonStyle(.plain)
    }
}

#Preview{
    RecipeItemChip(text: "Beef Burger", imageUrl: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg/medium", selected: false) {
        
    }
}

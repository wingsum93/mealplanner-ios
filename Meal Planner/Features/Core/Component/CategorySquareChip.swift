//
//  CategorySquareChip.swift
//  Meal Planner
//
//  Created by eric ho on 13/8/2025.
//
import SwiftUI

struct CategorySquareChip: View {
    var title: String
    var size: CGFloat = 88

    private var imageURL: URL? {
        // TheMealDB category images follow this pattern:
        // https://www.themealdb.com/images/category/{name}.png
        let formatted = title.replacingOccurrences(of: " ", with: "%20")
        return URL(string: "https://www.themealdb.com/images/category/\(formatted).png")
    }

    var body: some View {
        ZStack {
            // Background image
            AsyncImage(url: imageURL) { phase in
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
            .frame(width: size, height: size)
            .clipped()
            .cornerRadius(10)

            // Dark overlay
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.3))

            // Centered text
            Text(title)
                .font(.footnote.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
                .lineLimit(2)
                .shadow(radius: 3)
        }
        .frame(width: size, height: size)
    }
}


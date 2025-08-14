//
//  CategorySquareChip.swift
//  Meal Planner
//
//  Created by eric ho on 13/8/2025.
//
import SwiftUI

struct ImageSquareChip: View {
    var text: String
    var imageURL: URL? = nil
    var size: CGFloat = 88
    
    init(text: String,imageLink:String ,size: CGFloat=88) {
        self.text = text
        self.imageURL = URL(string: imageLink)
        self.size = size
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
            Text(text)
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

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            ForEach(1..<10) { index in
                ImageSquareChip(text: "Chicken",imageLink: "https://www.themealdb.com/images/category/Chicken.png")
            }
        }
        .padding(.horizontal)
    }
}

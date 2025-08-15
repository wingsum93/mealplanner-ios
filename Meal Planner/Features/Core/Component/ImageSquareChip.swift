//
//  CategorySquareChip.swift
//  Meal Planner
//
//  Created by eric ho on 13/8/2025.
//
import SwiftUI
import Kingfisher

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
            KFImage(imageURL)
                .placeholder {
                    Color.gray // 載入中顯示
                }
                .scaledToFill()
                .frame(width: size, height: size)
                .clipped()
                .cornerRadius(10)
                .overlay {
                    // Dark overlay
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.3))
                }
            
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

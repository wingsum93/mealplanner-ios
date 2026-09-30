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
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            KFImage(item.thumbURL)
                .placeholder {
                    Color.gray.allowsHitTesting(false) // 載入中顯示
                }
                .onFailureView {
                    ImageLoadFailureView()
                }
                .setProcessor(
                    DownsamplingImageProcessor(
                        size: CGSize(width: width * displayScale, height: width * displayScale)
                    )
                )
                .scaleFactor(displayScale)
                .cancelOnDisappear(true)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: width) // square image
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(item.name)
                .font(.subheadline)
                .lineLimit(1)

            TagChipsRow(
                tags: item.displayTags,
                availableWidth: width,
                spacing: 6
            )
        }
        .frame(width: width, height: width + 46, alignment: .leading)
        .padding(.bottom, 8)
    }
}
#Preview {
    RecipeCardSmall(item: .sample, width: 170)
}

//
//  RecipeListRow.swift
//  Meal Planner
//
//  Created by eric ho on 29/9/2026.
//
import SwiftUI
import Kingfisher

struct RecipeListRow<Accessory: View>: View {
    let item: UIRecipeItem
    private let accessory: () -> Accessory

    init(
        item: UIRecipeItem,
        @ViewBuilder accessory: @escaping () -> Accessory
    ) {
        self.item = item
        self.accessory = accessory
    }

    var body: some View {
        HStack(spacing: 12) {
            KFImage(item.thumbURL)
                .placeholder {
                    Color.gray
                }
                .onFailureView {
                    ImageLoadFailureView()
                }
                .resizable()
                .frame(width: 120, height: 80)
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(2)

                if let area = item.area, !area.isEmpty {
                    Text(area)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            accessory()
        }
        .padding(.vertical, 8)
    }
}

extension RecipeListRow where Accessory == EmptyView {
    init(item: UIRecipeItem) {
        self.item = item
        self.accessory = { EmptyView() }
    }
}

#Preview {
    RecipeListRow(item: .sample) {
        Image(systemName: "chevron.right")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}

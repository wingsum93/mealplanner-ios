//
//  TagChipsRow.swift
//  Meal Planner
//
//  Created by eric ho on 15/8/2025.
//
import SwiftUI

// --- 可複用的 Tag 列（單行，超出以 +N 顯示）---
struct TagChipsRow: View {
    let tags: [String]
    let availableWidth: CGFloat       // 由外面傳入！
    var spacing: CGFloat = 8
    var onTapTag: ((String) -> Void)? = nil
    var onTapMore: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(visibleIndices, id: \.self) { i in
                let tag = tags[i]
                TagChip(text: tag)
                    .onTapGesture { onTapTag?(tag) }
                    .fixedSize()
            }

            if overflowCount > 0 {
                TagChip(text: "+\(overflowCount)")
                    .onTapGesture { onTapMore?() }
                    .fixedSize()
            }
        }
        .frame(maxWidth: availableWidth, alignment: .leading)
    }

    private var visibleIndices: Range<Int> {
        0..<min(tags.count, 2)
    }

    private var overflowCount: Int {
        max(0, tags.count - visibleIndices.count)
    }
}

#Preview {
    TagChipsRow(
        tags: ["Beef", "Vegan", "Gluten Free", "Quick", "Italian", "Low Carb", "Dessert"],
        availableWidth: 100
    )
    .padding(.horizontal, 16)
}

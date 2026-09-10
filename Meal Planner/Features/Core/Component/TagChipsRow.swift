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
    
    @State private var chipWidths: [Int: CGFloat] = [:]
    @State private var moreWidth: CGFloat = 0

    var body: some View {
        let layout = computeLayout(
            availableWidth: availableWidth,
            chipWidths: chipWidths,
            spacing: spacing,
            tagsCount: tags.count,
            moreWidth: moreWidth
        )
        
        HStack(spacing: spacing) {
            ForEach(0..<layout.visibleCount, id: \.self) { i in
                let tag = tags[i]
                TagChip(text: tag)
                    .onTapGesture { onTapTag?(tag) }
                    .fixedSize()
                    .background(WidthReader(index: i, key: ChipWidthKey.self))
            }
            
            if layout.overflow > 0 {
                TagChip(text: "+\(layout.overflow)")
                    .onTapGesture { onTapMore?() }
                    .fixedSize()
                    .background(WidthReaderForMore(key: MoreWidthKey.self))
            }
        }
        .frame(maxWidth: availableWidth, alignment: .leading)
        .onPreferenceChange(ChipWidthKey.self) { chipWidths = $0 }
        .onPreferenceChange(MoreWidthKey.self) { moreWidth = $0 }
    }

        // Decide how many chips fit, reserving space for "+N" when needed
        private func computeLayout(
            availableWidth: CGFloat,
            chipWidths: [Int: CGFloat],
            spacing: CGFloat,
            tagsCount: Int,
            moreWidth: CGFloat
        ) -> (visibleCount: Int, overflow: Int) {
            guard tagsCount > 0 else { return (0, 0) }
            guard !chipWidths.isEmpty else {
                // First pass: show all—will settle once widths arrive
                return (tagsCount, 0)
            }

            // Pass 1: fit as many as possible without reserving +N
            var used: CGFloat = 0
            var visible = 0
            for i in 0..<tagsCount {
                guard let w = chipWidths[i] else { continue }
                let next = visible == 0 ? w : used + spacing + w
                if next <= availableWidth { used = next; visible += 1 } else { break }
            }
            let overflow1 = max(0, tagsCount - visible)
            guard overflow1 > 0 else { return (visible, 0) }

            // Pass 2: reserve space for "+N" chip and re-fit
            let reserve = (visible > 0 ? spacing : 0) + (moreWidth > 0 ? moreWidth : 44) // 44 = safe fallback
            let budget = max(0, availableWidth - reserve)

            used = 0
            visible = 0
            for i in 0..<tagsCount {
                guard let w = chipWidths[i] else { continue }
                let next = visible == 0 ? w : used + spacing + w
                if next <= budget { used = next; visible += 1 } else { break }
            }
            let overflow2 = max(0, tagsCount - visible)
            return (visible, overflow2)
        }
    }

// MARK: - Width readers

private struct WidthReader<Key: PreferenceKey>: View where Key.Value == [Int: CGFloat] {
    let index: Int
    let key: Key.Type
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: key, value: [index: proxy.size.width])
        }
    }
}

private struct WidthReaderForMore<Key: PreferenceKey>: View where Key.Value == CGFloat {
    let key: Key.Type
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: key, value: proxy.size.width)
        }
    }
}
private struct ChipWidthKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}
private struct MoreWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

#Preview {
    TagChipsRow(
        tags: ["Beef", "Vegan", "Gluten Free", "Quick", "Italian", "Low Carb", "Dessert"],
        availableWidth: 100
    )
    .padding(.horizontal, 16)
}

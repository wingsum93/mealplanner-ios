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
        let result = layoutResult(
            availableWidth: availableWidth,
            chipWidths: chipWidths,
            spacing: spacing)
        
        HStack(spacing: spacing) {
            ForEach(0..<result.visibleCount, id: \.self) { i in
                let tag = tags[i]
                TagChip(text: tag)
                    .onTapGesture { onTapTag?(tag) }
                    .fixedSize()
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: ChipWidthKey.self, value: [i: proxy.size.width])
                        }
                    )
            }
            if result.remaining > 0 {
                TagChip(text: "+\(result.remaining)")
                    .onTapGesture { onTapMore?() }
                    .fixedSize()
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: MoreWidthKey.self, value: proxy.size.width)
                        }
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onPreferenceChange(ChipWidthKey.self) { chipWidths = $0 }
        .onPreferenceChange(MoreWidthKey.self) { moreWidth = $0 }
    }

    // 計算可見 chips 數量，同時預留 +N chip 的寬度
    private func layoutResult(availableWidth: CGFloat,
                              chipWidths: [Int: CGFloat],
                              spacing: CGFloat) -> (visibleCount: Int, remaining: Int) {
        guard !tags.isEmpty, !chipWidths.isEmpty else {
            // 未量度到寬度時，先盡量估：暫時顯示全部（之後會自動收斂）
            return (tags.count, 0)
        }

        // 第一次：不預留 +N，看看最多放得落幾多
        var used: CGFloat = 0
        var visible = 0
        for i in 0..<tags.count {
            if let w = chipWidths[i] {
                let need = (visible == 0 ? w : used + spacing + w)
                if need <= availableWidth {
                    used = need
                    visible += 1
                } else { break }
            }
        }
        let overflow = tags.count - visible
        guard overflow > 0 else { return (visible, 0) }

        // 第二次：要預留 "+N" 的寬度再重算（N = overflow）
        let reserve = (visible > 0 ? spacing : 0) + (moreWidth > 0 ? moreWidth : 44) // 44 作為最低估
        used = 0
        visible = 0
        for i in 0..<tags.count {
            if let w = chipWidths[i] {
                // 預留 +N 空間
                let budget = availableWidth - reserve
                let need = (visible == 0 ? w : used + spacing + w)
                if need <= max(0, budget) {
                    used = need
                    visible += 1
                } else { break }
            }
        }
        return (visible, tags.count - visible)
    }
}

// --- PreferenceKey 用來量度每個 chip 的 width ---
private struct ChipWidthKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

private struct MoreWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    TagChipsRow(
        tags: ["Beef", "Vegan", "Gluten Free", "Quick", "Italian", "Low Carb", "Dessert"],
        availableWidth: 100
    )
    .padding(.horizontal, 16)
}

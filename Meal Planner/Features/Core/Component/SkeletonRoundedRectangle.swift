//
//  SkeletonRoundedRectangle.swift
//  Meal Planner
//
//  Created by Codex on 15/7/2026.
//
import SwiftUI

struct SkeletonRoundedRectangle: View {
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(.systemGray5))
            .shimmer(
                baseOpacity: 0.16,
                highlightOpacity: 0.72,
                background: Color(.systemGray4)
            )
    }
}

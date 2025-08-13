//
//  SkeletonHeroCard.swift
//  Meal Planner
//
//  Created by eric ho on 13/8/2025.
//
import SwiftUI

struct SkeletonHeroCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color(.systemGray5))
            .frame(height: 200)
            .shimmer() // Optional shimmer effect
    }
}

// Optional shimmer effect helper
private extension View {
    func shimmer(active: Bool = true) -> some View {
        self
            .redacted(reason: active ? .placeholder : [])
            .overlay(
                GeometryReader { geo in
                    Color.white
                        .opacity(0.3)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .white, .clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(30))
                        .offset(x: -geo.size.width)
                        .animation(
                            .linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                            value: UUID()
                        )
                }
            )
    }
}


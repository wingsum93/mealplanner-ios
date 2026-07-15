//
//  SkeletonHomePageView.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//
import SwiftUI

struct SkeletonHomePageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SkeletonHeroCard()
                .padding(.horizontal, 16)

            SkeletonSquareChipSection(title: "Areas")
            SkeletonSquareChipSection(title: "Categories")
            SkeletonDiscoverSection()
        }
        .accessibilityHidden(true)
    }
}

private struct SkeletonHeroCard: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SkeletonRoundedRectangle(cornerRadius: 14)
                .frame(height: 200)

            VStack(alignment: .leading, spacing: 8) {
                SkeletonRoundedRectangle(cornerRadius: 5)
                    .frame(width: 190, height: 18)

                SkeletonRoundedRectangle(cornerRadius: 4)
                    .frame(width: 86, height: 14)
            }
            .padding(12)
        }
        .frame(height: 200)
    }
}

private struct SkeletonSquareChipSection: View {
    let title: String

    var body: some View {
        SectionHeader(title)

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { _ in
                    SkeletonSquareChip()
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct SkeletonSquareChip: View {
    var body: some View {
        ZStack {
            SkeletonRoundedRectangle(cornerRadius: 10)

            VStack(spacing: 6) {
                SkeletonRoundedRectangle(cornerRadius: 4)
                    .frame(width: 54, height: 10)

                SkeletonRoundedRectangle(cornerRadius: 4)
                    .frame(width: 38, height: 10)
            }
        }
        .frame(width: 88, height: 88)
    }
}

private struct SkeletonDiscoverSection: View {
    var body: some View {
        SectionHeader("Discover")

        HStack(spacing: 8) {
            SkeletonRoundedRectangle(cornerRadius: 7)
                .frame(width: 16, height: 16)

            SkeletonRoundedRectangle(cornerRadius: 5)
                .frame(width: 106, height: 14)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    SkeletonRecipeCard()
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct SkeletonRecipeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SkeletonRoundedRectangle(cornerRadius: 12)
                .frame(width: 150, height: 150)

            SkeletonRoundedRectangle(cornerRadius: 5)
                .frame(width: 126, height: 14)

            HStack(spacing: 6) {
                SkeletonRoundedRectangle(cornerRadius: 8)
                    .frame(width: 52, height: 18)

                SkeletonRoundedRectangle(cornerRadius: 8)
                    .frame(width: 42, height: 18)
            }
        }
        .frame(width: 150, height: 190, alignment: .topLeading)
        .padding(.bottom, 8)
    }
}

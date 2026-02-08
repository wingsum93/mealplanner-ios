//
//  CardStackLayoutTests.swift
//  Meal PlannerTests
//
//  Created by Codex on 8/2/2026.
//

import Testing
import CoreGraphics
@testable import Meal_Planner

struct CardStackLayoutTests {

    @Test
    func topCardTransformIsNeutral() {
        let layout = CardStackLayout()

        #expect(layout.offset(for: 0) == .zero)
        #expect(near(layout.scale(for: 0), 1.0))
        #expect(near(layout.opacity(for: 0), 1.0))
    }

    @Test
    func backCardTransformsAreProgressive() {
        let layout = CardStackLayout()

        #expect(near(layout.offset(for: 1).height, 14))
        #expect(near(layout.offset(for: 2).height, 28))
        #expect(near(layout.scale(for: 1), 0.96))
        #expect(near(layout.scale(for: 2), 0.92))
        #expect(near(layout.opacity(for: 1), 0.90))
        #expect(near(layout.opacity(for: 2), 0.80))
    }

    @Test
    func visibleItemsCapAtThree() {
        let layout = CardStackLayout()
        let items = (0..<10).map { index in
            UIRecipeItem.new(id: "\(index)", name: "Meal \(index)")
        }

        let visible = layout.visibleItems(from: items)

        #expect(visible.count == 3)
        #expect(visible.map { $0.offset } == [0, 1, 2])
        #expect(visible.map { $0.element.id } == ["0", "1", "2"])
    }

    @Test
    func sizingUsesWidthFirstWhenHeightAllows() {
        let layout = CardStackLayout()
        let size = CGSize(width: 420, height: 900)

        let sizing = layout.sizing(in: size)
        let expectedWidth = size.width * CardStackLayout.cardWidthFactor
        let expectedHeight = expectedWidth / CardStackLayout.portraitWidthToHeight

        #expect(near(sizing.cardWidth, expectedWidth))
        #expect(near(sizing.cardHeight, expectedHeight))
    }

    @Test
    func sizingUsesPortraitNineBySixteenRatio() {
        let layout = CardStackLayout()
        let size = CGSize(width: 420, height: 800)

        let sizing = layout.sizing(in: size)

        #expect(near(sizing.cardWidth / sizing.cardHeight, CardStackLayout.portraitWidthToHeight))
    }

    @Test
    func heightIsCappedByAvailableStackHeight() {
        let layout = CardStackLayout()
        let size = CGSize(width: 400, height: 500)

        let sizing = layout.sizing(in: size)
        let expectedHeight = size.height - layout.totalPeekHeight

        #expect(near(sizing.cardHeight, expectedHeight))
        #expect(near(sizing.cardWidth, sizing.cardHeight * CardStackLayout.portraitWidthToHeight))
    }

    @Test
    func sizingFallsBackToPreferredSizeWhenAvailableHeightIsNonPositive() {
        let layout = CardStackLayout()
        let size = CGSize(width: 420, height: layout.totalPeekHeight - 4)

        let sizing = layout.sizing(in: size)
        let preferredWidth = size.width * CardStackLayout.cardWidthFactor
        let preferredHeight = preferredWidth / CardStackLayout.portraitWidthToHeight

        #expect(near(sizing.cardWidth, preferredWidth))
        #expect(near(sizing.cardHeight, preferredHeight))
        #expect(sizing.cardWidth > 0)
        #expect(sizing.cardHeight > 0)
    }

    @Test
    func stackHeightMatchesCardHeightPlusPeek() {
        let layout = CardStackLayout()
        let size = CGSize(width: 390, height: 780)

        let sizing = layout.sizing(in: size)
        #expect(near(sizing.stackHeight, sizing.cardHeight + layout.totalPeekHeight))
    }

    @Test
    func cappedHeightAlsoShrinksCardWidth() {
        let layout = CardStackLayout()
        let size = CGSize(width: 400, height: 500)

        let sizing = layout.sizing(in: size)
        let preferredWidth = size.width * CardStackLayout.cardWidthFactor

        #expect(sizing.cardWidth <= preferredWidth + 0.0001)
        #expect(sizing.cardWidth < preferredWidth)
    }

    @Test
    func cardWidthNeverExceedsConfiguredWidthFactor() {
        let layout = CardStackLayout()
        let sizes = [
            CGSize(width: 400, height: 500),
            CGSize(width: 420, height: 900),
            CGSize(width: 420, height: layout.totalPeekHeight - 4)
        ]

        for size in sizes {
            let sizing = layout.sizing(in: size)
            let preferredWidth = size.width * CardStackLayout.cardWidthFactor
            #expect(sizing.cardWidth <= preferredWidth + 0.0001)
        }
    }

    @Test
    func rotationUsesThirtyDegreesLimit() {
        #expect(near(CardStackLayout.rotationDegrees(dragX: 100, maxX: 100), 30))
        #expect(near(CardStackLayout.rotationDegrees(dragX: -100, maxX: 100), -30))
        #expect(near(CardStackLayout.rotationDegrees(dragX: 0, maxX: 100), 0))
    }

    private func near(_ lhs: CGFloat, _ rhs: CGFloat, tolerance: CGFloat = 0.0001) -> Bool {
        abs(lhs - rhs) <= tolerance
    }

    private func near(_ lhs: Double, _ rhs: Double, tolerance: Double = 0.0001) -> Bool {
        abs(lhs - rhs) <= tolerance
    }
}

//
//  CardStackView.swift
//  Meal Planner
//
//  Created by eric ho on 29/8/2025.
//
import SwiftUI
import Kingfisher

enum SwipeDirection {
    case left
    case right
}

struct CardStackLayout {
    static let maxVisibleCards = 3
    static let peekStep: CGFloat = 14
    static let cardWidthFactor: CGFloat = 0.85
    static let portraitWidthToHeight: CGFloat = 9.0 / 16.0
    static let maxRotationDegrees: Double = 30

    private let scales: [CGFloat] = [1.00, 0.96, 0.92]
    private let opacities: [Double] = [1.00, 0.90, 0.80]

    struct Sizing {
        let cardWidth: CGFloat
        let cardHeight: CGFloat
        let stackHeight: CGFloat
    }

    var totalPeekHeight: CGFloat {
        Self.peekStep * CGFloat(Self.maxVisibleCards - 1)
    }

    func visibleItems(from items: [UIRecipeItem]) -> [CardStackVisibleItem] {
        Array(items.prefix(Self.maxVisibleCards).enumerated()).map { offset, element in
            CardStackVisibleItem(offset: offset, element: element)
        }
    }

    func offset(for index: Int) -> CGSize {
        CGSize(width: 0, height: CGFloat(index) * Self.peekStep)
    }

    func scale(for index: Int) -> CGFloat {
        scales[clamped(index, upperBound: scales.count - 1)]
    }

    func opacity(for index: Int) -> Double {
        opacities[clamped(index, upperBound: opacities.count - 1)]
    }

    func sizing(in size: CGSize) -> Sizing {
        let preferredCardWidth = max(size.width * Self.cardWidthFactor, 1)
        let preferredCardHeight = preferredCardWidth / Self.portraitWidthToHeight
        let availableCardHeight = size.height - totalPeekHeight
        if availableCardHeight <= 0 {
            return Sizing(
                cardWidth: preferredCardWidth,
                cardHeight: preferredCardHeight,
                stackHeight: preferredCardHeight + totalPeekHeight
            )
        }
        let cardHeight = min(preferredCardHeight, availableCardHeight)
        let cardWidth = cardHeight * Self.portraitWidthToHeight
        return Sizing(
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            stackHeight: cardHeight + totalPeekHeight
        )
    }

    static func rotationDegrees(dragX: CGFloat, maxX: CGFloat) -> Double {
        guard maxX != 0 else { return 0 }
        return Double(dragX / maxX) * Self.maxRotationDegrees
    }

    private func clamped(_ value: Int, upperBound: Int) -> Int {
        min(max(value, 0), upperBound)
    }
}

struct CardStackVisibleItem: Identifiable, Equatable {
    let offset: Int
    let element: UIRecipeItem

    var id: String { element.id }
}

struct CardStackMetrics: Equatable {
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let stackHeight: CGFloat
    let arc: ArcDragGeometry

    init(size: CGSize, layout: CardStackLayout = CardStackLayout()) {
        let sizing = layout.sizing(in: size)
        cardWidth = sizing.cardWidth
        cardHeight = sizing.cardHeight
        stackHeight = sizing.stackHeight
        arc = ArcDragGeometry(
            maxX: sizing.cardWidth * 0.55,
            centerY: size.height * 1.5
        )
    }
}

struct CardStackView: View {
    @Binding var items: [UIRecipeItem]
    var onSwipe: ((UIRecipeItem, SwipeDirection) -> Void)?

    var body: some View {
        GeometryReader { proxy in
            CardStackContent(
                items: $items,
                metrics: CardStackMetrics(size: proxy.size),
                onSwipe: onSwipe
            )
        }
    }
}

private struct CardStackContent: View {
    @Binding var items: [UIRecipeItem]
    let metrics: CardStackMetrics
    let onSwipe: ((UIRecipeItem, SwipeDirection) -> Void)?

    @State private var dragOffset: CGSize = .zero
    @State private var dragTheta: CGFloat = 0
    @State private var swipeDirection: SwipeDirection?
    @State private var lastSwiped: (item: UIRecipeItem, direction: SwipeDirection)?
    @State private var isAnimatingOut = false

    private let layout = CardStackLayout()

    var body: some View {
        let visibleItems = layout.visibleItems(from: items)
        let topItem = visibleItems.first
        let backItems = Array(visibleItems.dropFirst())
        let rotation = CardStackLayout.rotationDegrees(dragX: dragOffset.width, maxX: metrics.arc.maxX)
        let swipeProgress = swipeProgress(for: metrics.arc)

        ZStack(alignment: .top) {
            CardStackBackCardsLayer(
                visibleItems: backItems,
                layout: layout,
                metrics: metrics
            )
            .equatable()

            if let topItem {
                CardStackTopCardLayer(
                    visibleItem: topItem,
                    layout: layout,
                    metrics: metrics,
                    dragOffset: dragOffset,
                    rotationDegrees: rotation,
                    swipeDirection: swipeDirection,
                    swipeProgress: swipeProgress,
                    onDragChanged: { value in
                        updateDrag(value, arc: metrics.arc)
                    },
                    onDragEnded: { value in
                        finishDrag(value, arc: metrics.arc)
                    }
                )
            }
        }
        .frame(width: metrics.cardWidth, height: metrics.stackHeight, alignment: .top)
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .bottom) {
            if let lastSwiped {
                CardStackUndoButton(
                    isDisabled: isAnimatingOut,
                    action: {
                        undoSwipe(last: lastSwiped, arc: metrics.arc)
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: visibleItems)
    }

    private func updateDrag(_ value: DragGesture.Value, arc: ArcDragGeometry) {
        guard items.first != nil, !isAnimatingOut else { return }
        let result = arc.offset(for: value.translation.width)
        dragOffset = result.offset
        dragTheta = result.theta
        swipeDirection = result.offset.width > 0 ? .right : result.offset.width < 0 ? .left : nil
    }

    private func finishDrag(_ value: DragGesture.Value, arc: ArcDragGeometry) {
        guard items.first != nil, !isAnimatingOut else { return }
        let result = arc.offset(for: value.translation.width)
        if arc.isBeyondThreshold(theta: result.theta) {
            performSwipe(direction: result.offset.width >= 0 ? .right : .left, arc: arc)
        } else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                dragOffset = .zero
                dragTheta = 0
                swipeDirection = nil
            }
        }
    }

    private func performSwipe(direction: SwipeDirection, arc: ArcDragGeometry) {
        guard let item = items.first else { return }
        let sign: CGFloat = direction == .right ? 1 : -1
        let finalOffset = CGSize(width: arc.maxX * 1.35 * sign, height: arc.maxYOffset)

        isAnimatingOut = true
        swipeDirection = direction
        withAnimation(.easeInOut(duration: 0.25)) {
            dragOffset = finalOffset
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            _ = withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                items.removeFirst()
            }
            lastSwiped = (item: item, direction: direction)
            onSwipe?(item, direction)
            dragOffset = .zero
            dragTheta = 0
            swipeDirection = nil
            isAnimatingOut = false
        }
    }

    private func undoSwipe(last: (item: UIRecipeItem, direction: SwipeDirection), arc: ArcDragGeometry) {
        guard !isAnimatingOut else { return }
        let sign: CGFloat = last.direction == .right ? 1 : -1
        let startOffset = CGSize(width: arc.maxX * 1.1 * sign, height: arc.maxYOffset)

        isAnimatingOut = true
        lastSwiped = nil
        withAnimation(.none) {
            items.insert(last.item, at: 0)
            dragOffset = startOffset
        }
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                dragOffset = .zero
            }
            dragTheta = 0
            swipeDirection = nil
            isAnimatingOut = false
        }
    }

    private func swipeProgress(for arc: ArcDragGeometry) -> CGFloat {
        guard arc.thetaMax != 0 else { return 0 }
        return min(dragTheta / arc.thetaMax, 1)
    }
}

private enum RandomPickAccessibilityID {
    static let topCard = "randomPick.topCard"
    static let topCardImage = "randomPick.topCard.image"
}

struct ArcDragGeometry: Equatable {
    let maxX: CGFloat
    let maxYOffset: CGFloat
    let centerY: CGFloat
    let radius: CGFloat
    let thetaMax: CGFloat

    init(maxX: CGFloat, centerY: CGFloat) {
        let safeMaxX = max(maxX, 0)
        let safeCenterY = max(centerY, safeMaxX + 1)
        let safeRadius = safeCenterY

        self.maxX = safeMaxX
        self.centerY = safeCenterY
        radius = safeRadius
        thetaMax = safeRadius == 0 ? 0 : asin(min(safeMaxX / safeRadius, 1))
        maxYOffset = Self.yOffset(for: safeMaxX, centerY: safeCenterY, radius: safeRadius)
    }

    func offset(for translationX: CGFloat) -> (offset: CGSize, theta: CGFloat) {
        let clampedX = min(max(translationX, -maxX), maxX)
        let theta = radius == 0 ? 0 : asin(min(abs(clampedX) / radius, 1))
        let y = Self.yOffset(for: clampedX, centerY: centerY, radius: radius)
        return (CGSize(width: clampedX, height: y), theta)
    }

    func isBeyondThreshold(theta: CGFloat) -> Bool {
        theta >= thetaMax * 0.2
    }

    private static func yOffset(for x: CGFloat, centerY: CGFloat, radius: CGFloat) -> CGFloat {
        centerY - sqrt(max((radius * radius) - (x * x), 0))
    }
}

private struct SwipeCardView: View {
    let item: UIRecipeItem
    let isTopCard: Bool
    let swipeDirection: SwipeDirection?
    let swipeProgress: CGFloat
    private let cardShape = RoundedRectangle(cornerRadius: 28, style: .continuous)
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        cardShape
            .fill(Color(.systemGray5))
            .overlay {
                imageLayer
            }
            .overlay {
                LinearGradient(
                    colors: [.clear, .black.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    if let area = item.area, let category = item.category {
                        Text("\(area) • \(category)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                .padding(20)
            }
            .overlay {
                SwipeCardFeedbackOverlay(
                    direction: swipeDirection,
                    progress: swipeProgress
                )
            }
        .clipShape(cardShape)
        .contentShape(cardShape)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(isTopCard ? RandomPickAccessibilityID.topCard : "randomPick.card")
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 8)
    }

    private var imageLayer: some View {
        KFImage(item.thumbURL)
            .placeholder {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        ProgressView()
                    )
            }
            .onFailureView {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
            }
            .setProcessor(
                DownsamplingImageProcessor(
                    size: CGSize(width: 340 * displayScale, height: 604 * displayScale)
                )
            )
            .scaleFactor(displayScale)
            .cancelOnDisappear(true)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier(isTopCard ? RandomPickAccessibilityID.topCardImage : "randomPick.card.image")
    }
}

private struct CardStackBackCardsLayer: View, Equatable {
    let visibleItems: [CardStackVisibleItem]
    let layout: CardStackLayout
    let metrics: CardStackMetrics

    static func == (lhs: CardStackBackCardsLayer, rhs: CardStackBackCardsLayer) -> Bool {
        lhs.visibleItems == rhs.visibleItems && lhs.metrics == rhs.metrics
    }

    var body: some View {
        ZStack(alignment: .top) {
            ForEach(visibleItems) { visibleItem in
                let index = visibleItem.offset

                SwipeCardView(
                    item: visibleItem.element,
                    isTopCard: false,
                    swipeDirection: nil,
                    swipeProgress: 0
                )
                .frame(width: metrics.cardWidth, height: metrics.cardHeight)
                .scaleEffect(layout.scale(for: index), anchor: .top)
                .opacity(layout.opacity(for: index))
                .offset(layout.offset(for: index))
                .zIndex(Double(visibleItems.count - index))
                .allowsHitTesting(false)
            }
        }
        .frame(width: metrics.cardWidth, height: metrics.stackHeight, alignment: .top)
    }
}

private struct CardStackTopCardLayer: View {
    let visibleItem: CardStackVisibleItem
    let layout: CardStackLayout
    let metrics: CardStackMetrics
    let dragOffset: CGSize
    let rotationDegrees: Double
    let swipeDirection: SwipeDirection?
    let swipeProgress: CGFloat
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void

    var body: some View {
        SwipeCardView(
            item: visibleItem.element,
            isTopCard: true,
            swipeDirection: swipeDirection,
            swipeProgress: swipeProgress
        )
        .frame(width: metrics.cardWidth, height: metrics.cardHeight)
        .scaleEffect(layout.scale(for: visibleItem.offset), anchor: .top)
        .opacity(layout.opacity(for: visibleItem.offset))
        .offset(layout.offset(for: visibleItem.offset))
        .offset(dragOffset)
        .rotationEffect(Angle(degrees: rotationDegrees))
        .zIndex(Double(CardStackLayout.maxVisibleCards))
        .allowsHitTesting(true)
        .gesture(dragGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged(onDragChanged)
            .onEnded(onDragEnded)
    }
}

private struct CardStackUndoButton: View {
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Undo", systemImage: "arrow.uturn.backward")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(.bottom, 8)
        .disabled(isDisabled)
    }
}

private struct SwipeCardFeedbackOverlay: View {
    let direction: SwipeDirection?
    let progress: CGFloat

    var body: some View {
        ZStack {
            if let direction {
                Color(direction == .right ? .systemRed : .systemGray)
                    .opacity(min(progress * 0.45, 0.35))

                Image(systemName: direction == .right ? "heart.fill" : "xmark")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(radius: 8)
                    .opacity(min(progress * 1.2, 1))
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    CardStackView(items: .constant([
        .sample,
        .new(id: "2", name: "Spiced Noodles"),
        .new(id: "3", name: "Citrus Salad"),
        .new(id: "4", name: "Veggie Sushi"),
        .new(id: "5", name: "Miso Ramen")
    ]))
    .padding()
    .background(Color(.systemGroupedBackground))
}

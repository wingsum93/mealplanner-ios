//
//  CardStackView.swift
//  Meal Planner
//
//  Created by eric ho on 29/8/2025.
//
import SwiftUI

enum SwipeDirection {
    case left
    case right
}

struct CardStackLayout {
    static let maxVisibleCards = 3
    static let peekStep: CGFloat = 14
    static let cardWidthFactor: CGFloat = 0.85
    static let portraitWidthToHeight: CGFloat = 9.0 / 16.0
    static let maxVisibleHeightFactor: CGFloat = 0.58
    static let minimumCardHeight: CGFloat = 240
    static let maxRotationDegrees: Double = 3.5

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

    func visibleItems(from items: [UIRecipeItem]) -> [(offset: Int, element: UIRecipeItem)] {
        Array(items.prefix(Self.maxVisibleCards).enumerated())
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
        let maxCardWidth = size.width * Self.cardWidthFactor
        let rawCardHeight = maxCardWidth / Self.portraitWidthToHeight
        let maxVisibleCardHeight = (size.height * Self.maxVisibleHeightFactor) - totalPeekHeight
        let cappedCardHeight = min(rawCardHeight, maxVisibleCardHeight)
        let cardHeight = max(cappedCardHeight, Self.minimumCardHeight)
        let cardWidth = min(maxCardWidth, cardHeight * Self.portraitWidthToHeight)
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

struct CardStackView: View {
    @Binding var items: [UIRecipeItem]
    var onSwipe: ((UIRecipeItem, SwipeDirection) -> Void)?

    @State private var dragOffset: CGSize = .zero
    @State private var dragTheta: CGFloat = 0
    @State private var swipeDirection: SwipeDirection?
    @State private var lastSwiped: (item: UIRecipeItem, direction: SwipeDirection)?
    @State private var isAnimatingOut = false

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let layout = CardStackLayout()
            let sizing = layout.sizing(in: size)
            let cardWidth = sizing.cardWidth
            let cardHeight = sizing.cardHeight
            let stackHeight = sizing.stackHeight
            let visibleItems = layout.visibleItems(from: items)
            let arc = ArcDragGeometry(
                maxX: cardWidth * 0.55,
                maxYOffset: -cardHeight * 0.2
            )

            ZStack(alignment: .top) {
                ZStack(alignment: .top) {
                    ForEach(visibleItems, id: \.offset) { index, item in
                        SwipeCardView(item: item)
                            .frame(width: cardWidth, height: cardHeight)
                            .scaleEffect(layout.scale(for: index), anchor: .top)
                            .opacity(layout.opacity(for: index))
                            .offset(layout.offset(for: index))
                            .offset(index == 0 ? dragOffset : .zero)
                            .rotationEffect(index == 0 ? Angle(degrees: rotation(for: arc)) : .zero)
                            .overlay(alignment: .center) {
                                if index == 0 {
                                    swipeOverlay(arc: arc)
                                }
                            }
                            .zIndex(Double(visibleItems.count - index))
                            .allowsHitTesting(index == 0)
                            .gesture(index == 0 ? dragGesture(arc: arc) : nil)
                            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: dragOffset)
                            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: items)
                    }
                }
                .frame(height: stackHeight, alignment: .top)
                .frame(maxWidth: .infinity, alignment: .top)

                if let lastSwiped {
                    VStack {
                        Spacer()
                        undoButton(for: lastSwiped, arc: arc)
                    }
                    .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private func dragGesture(arc: ArcDragGeometry) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard items.first != nil, !isAnimatingOut else { return }
                let result = arc.offset(for: value.translation.width)
                dragOffset = result.offset
                dragTheta = result.theta
                swipeDirection = result.offset.width > 0 ? .right : result.offset.width < 0 ? .left : nil
            }
            .onEnded { value in
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

    private func undoButton(for last: (item: UIRecipeItem, direction: SwipeDirection), arc: ArcDragGeometry) -> some View {
        Button {
            undoSwipe(last: last, arc: arc)
        } label: {
            Label("Undo", systemImage: "arrow.uturn.backward")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(.bottom, 8)
        .disabled(isAnimatingOut)
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

    private func rotation(for arc: ArcDragGeometry) -> Double {
        CardStackLayout.rotationDegrees(dragX: dragOffset.width, maxX: arc.maxX)
    }

    private func swipeOverlay(arc: ArcDragGeometry) -> some View {
        let progress = arc.thetaMax == 0 ? 0 : min(dragTheta / arc.thetaMax, 1)
        let opacity = min(progress * 0.45, 0.35)

        return ZStack {
            if let swipeDirection {
                Color(swipeDirection == .right ? .systemRed : .systemGray)
                    .opacity(opacity)

                Image(systemName: swipeDirection == .right ? "heart.fill" : "forward.fill")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(radius: 8)
                    .opacity(min(progress * 1.2, 1))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private struct ArcDragGeometry {
    let maxX: CGFloat
    let maxYOffset: CGFloat
    let centerY: CGFloat
    let radius: CGFloat
    let thetaMax: CGFloat

    init(maxX: CGFloat, maxYOffset: CGFloat) {
        let safeYOffset = maxYOffset == 0 ? -1 : maxYOffset
        self.maxX = maxX
        self.maxYOffset = safeYOffset
        let center = (maxX * maxX + safeYOffset * safeYOffset) / (2 * safeYOffset)
        centerY = center
        radius = abs(center)
        thetaMax = radius == 0 ? 0 : asin(maxX / radius)
    }

    func offset(for translationX: CGFloat) -> (offset: CGSize, theta: CGFloat) {
        let clampedX = min(max(translationX, -maxX), maxX)
        let theta = asin(abs(clampedX) / radius)
        let y = centerY + radius * cos(theta)
        return (CGSize(width: clampedX, height: y), theta)
    }

    func isBeyondThreshold(theta: CGFloat) -> Bool {
        theta >= thetaMax * 0.2
    }
}

private struct SwipeCardView: View {
    let item: UIRecipeItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: item.thumbURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            ProgressView()
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )

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
        .compositingGroup()
        .mask(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 8)
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

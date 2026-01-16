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
            let arc = ArcDragGeometry(
                maxX: size.width * 0.55,
                maxYOffset: -size.height * 0.2
            )

            ZStack {
                ForEach(Array(items.prefix(10).enumerated()), id: \.element.id) { index, item in
                    SwipeCardView(item: item)
                        .frame(
                            width: size.width * 0.85,
                            height: (size.width * 0.85) * (16.0 / 9.0)
                        )
                        .offset(stackOffset(for: index))
                        .offset(index == 0 ? dragOffset : .zero)
                        .rotationEffect(index == 0 ? Angle(degrees: rotation(for: arc)) : .zero)
                        .overlay(alignment: .center) {
                            if index == 0 {
                                swipeOverlay(arc: arc)
                            }
                        }
                        .zIndex(Double(items.count - index))
                        .gesture(index == 0 ? dragGesture(arc: arc) : nil)
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: dragOffset)
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: items)
                }

                if let lastSwiped {
                    VStack {
                        Spacer()
                        undoButton(for: lastSwiped, arc: arc)
                    }
                    .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minHeight: 420)
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
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
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
        guard arc.maxX != 0 else { return 0 }
        return Double(dragOffset.width / arc.maxX) * 6
    }

    private func stackOffset(for index: Int) -> CGSize {
        CGSize(width: CGFloat(index) * 6, height: CGFloat(index) * 12)
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
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
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

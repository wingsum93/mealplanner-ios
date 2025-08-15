//
//  ViewModelExtensions.swift
//  Meal Planner
//
//  Created by eric ho on 5/8/2025.
//
import SwiftUI

extension FeatureViewModel {
    //    static var preview: FeatureViewModel {
    //        let vm = FeatureViewModel(repository: DummyRecipeRepository())
    //        vm.state = HomeScreenState(
    //            isLoading: false,
    //            errorMessage: nil,
    //            randomRecipe: .sample,
    //            areaList: ["American", "British", "Chinese"],
    //            categoryList: ["Dessert", "Seafood"],
    //            beefRecipes: [.sample, .sample]
    //        )
    //        return vm
    //    }
}

public extension View{
    /// 方便呼叫嘅 sugar
    func shimmer(
        _ isActive: Bool = true,
        duration: Double = 1.4,
        bounce: Bool = false,
        angle: Angle = .degrees(20),
        baseOpacity: Double = 0.28,
        highlightOpacity: Double = 0.9,
        highlightWidth: CGFloat = 200,
        background: Color = .gray,          // skeleton 底色（會乘 baseOpacity）
        highlight: Color = .white           // 高光色
    ) -> some View {
        modifier(
            ShimmerModifier(
                isActive: isActive,
                duration: duration,
                bounce: bounce,
                angle: angle,
                baseOpacity: baseOpacity,
                highlightOpacity: highlightOpacity,
                highlightWidth: highlightWidth,
                background: background,
                highlight: highlight
            )
        )
    }
}
struct ShimmerModifier :ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Controls
    var isActive: Bool
    var duration: Double
    var bounce: Bool
    var angle: Angle
    var baseOpacity: Double
    var highlightOpacity: Double
    var highlightWidth: CGFloat
    var background: Color
    var highlight: Color
    
    func body(content: Content) -> some View {
        content
        // 基底打底，讓 placeholder/skeleton 有淡色背景
            .overlay(
                background.opacity(baseOpacity)
            )
        // 疊一層會滑動嘅高光遮罩
            .overlay(
                GeometryReader { geo in
                    ShimmerStripe(
                        isActive: isActive,
                        duration: duration,
                        bounce: bounce,
                        angle: angle,
                        highlightOpacity: highlightOpacity,
                        highlightWidth: highlightWidth,
                        highlight: highlight,
                        reduceMotion: reduceMotion,
                        size: geo.size
                    )
                    .allowsHitTesting(false)
                }
            )
        // 用原 content 當作遮罩，確保高光只在內容範圍內出現
            .mask(content)
    }
}
private struct ShimmerStripe: View {
    var isActive: Bool
    var duration: Double
    var bounce: Bool
    var angle: Angle
    var highlightOpacity: Double
    var highlightWidth: CGFloat
    var highlight: Color
    var reduceMotion: Bool
    var size: CGSize
    
    @State private var phase: CGFloat = -1.2 // 從左側外面開始
    
    var body: some View {
        // 做一條斜向光帶：透明 -> 高光 -> 透明
        let gradient = LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .clear, location: 0.0),
                .init(color: highlight.opacity(highlightOpacity), location: 0.5),
                .init(color: .clear, location: 1.0),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // 光帶開到比視圖大，避免旋轉後露邊
        let beltWidth  = max(size.width, size.height) * 3
        let beltHeight = beltWidth
        
        Rectangle()
            .fill(gradient)
            .frame(width: beltWidth, height: beltHeight)
            .rotationEffect(angle)
        // phase -1.2 → 1.2 橫移穿過整個區域
            .offset(x: phase * beltWidth * 0.5, y: 0)
            .opacity(isActive ? 1 : 0)
            .onAppear(perform: animateIfNeeded)
            .onChange(of: isActive) { _ in animateIfNeeded() }
    }
    
    private func animateIfNeeded() {
        guard isActive else {
            // 停止時把光帶收返去左側
            phase = -1.2
            return
        }
        guard !reduceMotion else {
            // 減少動態：保留靜態高光，不做動畫
            phase = 0.0
            return
        }
        phase = -1.2
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: bounce)) {
            phase = 1.2
        }
    }
}

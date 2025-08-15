//
//  LottieView.swift
//  Meal Planner
//
//  Created by eric ho on 15/8/2025.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode

    init(animationName: String, loopMode: LottieLoopMode = .loop) {
        self.animationName = animationName
        self.loopMode = loopMode
    }

    func makeUIView(context: Context) -> some UIView {
        let view = LottieAnimationView(name: animationName)
        view.loopMode = loopMode
        view.play()
        view.contentMode = .scaleAspectFit
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Nothing needed
    }
}

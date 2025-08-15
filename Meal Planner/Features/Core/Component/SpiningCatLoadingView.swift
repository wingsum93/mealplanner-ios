//
//  SpCatLoadingView.swift
//  Meal Planner
//
//  Created by eric ho on 15/8/2025.
//

import SwiftUI

struct SpiningCatLoadingView: View {
    var message: String? = nil
    var animationName: String = "spining-cat-loading" // 你的 JSON 檔案名（不含 .json）

    var body: some View {
        VStack(spacing: 12) {
            LottieView(animationName: animationName)
                .frame(width: 100, height: 100)

            if let message = message {
                Text(message)
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).opacity(0.8))
    }
}

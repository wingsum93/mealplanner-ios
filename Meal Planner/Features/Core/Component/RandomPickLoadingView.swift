//
//  RandomPickLoadingView.swift
//  Meal Planner
//
//  Created by eric ho on 31/8/2025.
//

import SwiftUI

struct RandomPickLoadingView: View {
    var message: String

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.35), Color.pink.opacity(0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                ProgressView()
                    .scaleEffect(1.4)
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                    .offset(y: -36)
            }

            VStack(spacing: 6) {
                Text("Picking something delicious")
                    .font(.title3.weight(.semibold))
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color.orange.opacity(0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    RandomPickLoadingView(message: "Rolling the dice for 10 fresh picks.")
}

//
//  EmptyStateView.swift
//  Meal Planner
//
//  Created by eric ho on 10/8/2025.
//
import SwiftUI

struct EmptyStateView: View {
    private let title: String?
    private let description: String
    var systemImage: String = "magnifyingglass"
    var actionTitle: String? = nil
    var onAction: (() -> Void)? = nil

    init(
        message: String,
        systemImage: String = "magnifyingglass",
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.title = nil
        self.description = message
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.onAction = onAction
    }

    init(
        title: String,
        description: String,
        systemImage: String = "magnifyingglass",
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.onAction = onAction
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)

            if let title {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            if let actionTitle = actionTitle, let onAction = onAction {
                Button(action: onAction) {
                    Text(actionTitle)
                        .font(.body.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(Color.accentColor.opacity(0.1))
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

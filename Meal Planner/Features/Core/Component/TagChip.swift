//
//  TagChip.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//
import SwiftUI

struct TagChip: View {
    let text: String
    let textColor: Color
    let backgroundColor: Color
    let strokeColor: Color
    
    init(
        text: String,
        textColor: Color = .primary,
        backgroundColor: Color = .secondary.opacity(0.12),
        strokeColor: Color = Color.gray.opacity(0.3)) {
            self.text = text
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.strokeColor = strokeColor
        }
    
    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .foregroundColor(textColor)
            .frame(minHeight: 30)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                backgroundColor.opacity(0.28),
                                Color.primary.opacity(0.10),
                                Color.secondary.opacity(0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                strokeColor.opacity(0.55),
                                Color.primary.opacity(0.24),
                                Color.secondary.opacity(0.18)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.primary.opacity(0.08), radius: 4, x: 0, y: 2)
            .contentShape(Capsule()) // 點擊區域貼合形狀
            .accessibilityLabel(Text("Tag: \(text)"))
    }
}

#Preview("anvs") {
    TagChip(text: "Beef", textColor: .primary, backgroundColor: .secondary.opacity(0.12))
}
#Preview("2nd") {
    TagChip(text: "Beef", textColor: .white, backgroundColor: .blue)
}

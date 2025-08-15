//
//  TagChip.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//
import SwiftUI

struct TagChip:View {
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
            .font(.caption)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundColor(textColor)
            .background(
                Capsule().fill(Color(backgroundColor))
            )
            .overlay(
                Capsule().stroke(strokeColor, lineWidth: 1)
            ).contentShape(Capsule()) // 點擊區域貼合形狀
            .accessibilityLabel(Text("Tag: \(text)"))
    }
}

#Preview("anvs") {
    TagChip(text: "Beef",textColor: .primary,backgroundColor: .secondary.opacity(0.12))
}
#Preview("2nd"){
    TagChip(text: "Beef",textColor: .white,backgroundColor: .blue)
}

//
//  TagChip.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//
import SwiftUI

struct TagChip:View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Color(.systemGray6))
            )
            .overlay(
                Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

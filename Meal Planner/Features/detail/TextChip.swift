//
//  TextChip.swift
//  Meal Planner
//
//  Created by eric ho on 15/8/2025.
//
import SwiftUI

struct TextChip: View {
    let text: String


    var body: some View {
        
        Text(text)
        
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(.thinMaterial)
        )
        .foregroundStyle(.primary)
    }
}

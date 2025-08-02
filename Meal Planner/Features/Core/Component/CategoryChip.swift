//
//  CategoryChip.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI

import SwiftUI

struct CategoryChip: View {
    let label: String
    let selected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(selected ? Color.accentColor : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.4), lineWidth: selected ? 0 : 1)
                    )
                    .shadow(color: selected ? .black.opacity(0.2) : .clear, radius: 6, x: 0, y: 4)

                Text(label)
                    .foregroundColor(selected ? .white : .primary)
                    .fontWeight(selected ? .semibold : .regular)
            }
            .frame(width: 80, height: 80)
            .scaleEffect(selected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: selected)
        }
        .buttonStyle(.plain)
    }
}


#Preview{
    CategoryChip(label: "adult", selected: false) {}
    CategoryChip(label: "adult", selected: true) {}
}


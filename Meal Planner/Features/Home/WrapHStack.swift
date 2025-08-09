//
//  WrapHStack.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//
import SwiftUI

struct WrapHStack<T: Hashable, Content: View>:View {
    let items: [T]
    let spacing: CGFloat
    let content: (T) -> Content
    
    init(items: [T], spacing: CGFloat = 8, @ViewBuilder content: @escaping (T) -> Content) {
        self.items = items
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        FlowLayout(
            mode: .scrollable,
            items: items,
            spacing: spacing,
            content: content
        )
    }
}

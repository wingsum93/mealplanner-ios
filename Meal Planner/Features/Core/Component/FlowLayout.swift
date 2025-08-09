//
//  FlowLayout.swift
//  Meal Planner
//
//  Created by eric ho on 4/8/2025.
//

import SwiftUI

struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    enum Mode { case scrollable, vstack }

    let mode: Mode
    let items: Data
    let spacing: CGFloat
    @ViewBuilder let content: (Data.Element) -> Content

    init(
        mode: Mode,
        items: Data,
        spacing: CGFloat = 8,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.mode = mode
        self.items = items
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        Group {
            switch mode {
            case .scrollable:
                ScrollView(.vertical, showsIndicators: false) {
                    WrapLayout(horizontalSpacing: spacing, verticalSpacing: spacing) {
                        ForEach(Array(items), id: \.self) { item in
                            content(item)
                        }
                    }
                    .padding(.horizontal, 0) // adjust if you like
                }
            case .vstack:
                WrapLayout(horizontalSpacing: spacing, verticalSpacing: spacing) {
                    ForEach(Array(items), id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }
}

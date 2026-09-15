//
//  ImageLoadFailureView.swift
//  Meal Planner
//
//  Created by eric ho on 16/9/2026.
//

import SwiftUI

struct ImageLoadFailureView: View {
    var iconSize: CGFloat = 24

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(.systemGray5))

            Image(systemName: "questionmark")
                .font(.system(size: iconSize, weight: .bold))
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    ImageLoadFailureView(iconSize: 64)
}


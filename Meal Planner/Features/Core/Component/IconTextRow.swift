//
//  ImageLabelRow.swift
//  Meal Planner
//
//  Created by eric ho on 30/10/2025.
//
import SwiftUI

struct IconTextRow:View{
    let text: String
    let systemImage: String
    var body: some View {
        Label { Text(text) } icon: { Image(systemName: systemImage) }
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(.thinMaterial))
            .foregroundStyle(.primary)
    }
}

#Preview{
    IconTextRow(text: "apple", systemImage: "applelogo")
}
#Preview("chicken"){
    IconTextRow(text: "cheicken", systemImage: "meat.fill")
}
#Preview("beef"){
    IconTextRow(text: "beef", systemImage: ImageUtil.getCategorySystemImage(category: "beef"))
}

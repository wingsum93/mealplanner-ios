//
//  SearchBar.swift
//  Meal Planner
//
//  Created by eric ho on 14/8/2025.
//
import SwiftUI

struct SearchBar: View {
    var placeholder: String
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            Text(placeholder)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
        .contentShape(Rectangle()) // ensures full tap area
        .onTapGesture(perform: onTap)
    }
}
#Preview {
    SearchBar(placeholder: "Search", onTap: { })
}

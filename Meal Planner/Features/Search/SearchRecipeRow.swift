//
//  RecipeRow.swift
//  Meal Planner
//
//  Created by eric ho on 10/8/2025.
//
import SwiftUI

struct SearchRecipeRow: View {
    let item: UIRecipeItem
    var showFavorite: Bool = false
    var onFavoriteToggle: ((Bool) -> Void)? = nil
    var showMastered: Bool = false
    var isMastered: Bool = false
    var onMasteredToggle: ((Bool) -> Void)? = nil

    var body: some View {
        RecipeListRow(item: item) {
            if showFavorite, let onFavoriteToggle = onFavoriteToggle {
                Button {
                    onFavoriteToggle(!item.isFavorite)
                } label: {
                    Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(item.isFavorite ? .red : .secondary)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
            }

            if showMastered, let onMasteredToggle = onMasteredToggle {
                Button {
                    onMasteredToggle(!isMastered)
                } label: {
                    Image(systemName: isMastered ? "checkmark.seal.fill" : "checkmark.seal")
                        .foregroundColor(isMastered ? .accentColor : .secondary)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
            }
        }
    }
}


#Preview {
    SearchRecipeRow(item: UIRecipeItem.sample, showFavorite: true, onFavoriteToggle: {_ in })
}

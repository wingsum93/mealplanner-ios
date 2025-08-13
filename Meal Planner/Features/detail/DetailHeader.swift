//
//  DetailHeader.swift
//  Meal Planner
//
//  Created by eric ho on 10/8/2025.
//
import SwiftUI

struct DetailHeader: View {
  let item: UIRecipeItem
  let heroNS: Namespace.ID

  var body: some View {
    AsyncImage(url: item.thumbURL) { img in
      img.resizable().scaledToFill()
    } placeholder: {
      Rectangle().fill(.gray.opacity(0.2))
    }
    .matchedGeometryEffect(id: item.id, in: heroNS)
    .frame(height: 300)
    .clipShape(RoundedRectangle(cornerRadius: 0))
  }
}

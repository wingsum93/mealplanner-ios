//
//  DetailSheetView.swift
//  Meal Planner
//
//  Created by eric ho on 17/8/2025.
//
import SwiftUI
import Kingfisher

struct DetailSheetView: View {
    @ObservedObject var vm: DetailViewModel

    var body: some View {
        // If nil, show nothing (sheet can still be presented/animated by parent)
        if let item = vm.state.item {
            ScrollView {
                VStack(spacing: 16) {
                    // Header image
                    KFImage(item.thumbURL)
                        .placeholder {
                            Rectangle().fill(Color(.systemGray5))
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(height: 280)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.45)],
                                startPoint: .center, endPoint: .bottom
                            )
                        )
                        .overlay(alignment: .bottomLeading) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.name)
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                    .shadow(radius: 4)

                                HStack(spacing: 8) {
                                    if let area = item.area, !area.isEmpty {
                                        MetaChip(text: area, systemImage: "globe.asia.australia.fill")
                                    }
                                    if let cat = item.category, !cat.isEmpty {
                                        MetaChip(text: cat, systemImage: "square.grid.2x2")
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                        }
                        .onLongPressGesture {
                            print("my id is = " + item.id)
                        }

                    // Actions row
                    HStack(spacing: 12) {
                        Button {
                            vm.onIntent(.toggleFavorite)
                        } label: {
                            Label(item.isFavorite ? "Favourited" : "Add to Favourites",
                                  systemImage: item.isFavorite ? "heart.fill" : "heart")
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(Color.accentColor.opacity(0.12)))
                        }
                    }
                    .padding(.horizontal, 16)

                    //Description
                    Text("Description")
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.leading, 8)
                    Text(item.description)
                        .font(.caption)
                        .fontWeight(.regular)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.leading, 8)
                    
                    //Instruction
                    HStack(spacing: 8){
                        Image(systemName: "applelogo")              // 修正 "apple.fill" -> "applelogo"
                                .imageScale(.medium)
                                .font(.title2)                          // 跟文字同尺寸，動態字級會一起放大
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(.secondary)            // 讓 icon 不搶戲
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .foregroundStyle(.primary)
                            .accessibilityAddTraits(.isHeader)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    
                    VStack(alignment: .leading){
                        ForEach(item.instructions.indices,id:\.self){ num in
                            let text = "\(num+1). "
                            let text2 = item.instructions[num]
                            HStack{
                                Text(text)
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                Text(text2)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            if num != item.instructions.count-1 {
                                Spacer(minLength: 10)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading){
                        // Ingredients
                        HStack(spacing: 8){
                            Image(systemName: "arrow.triangle.2.circlepath")              // 修正 "apple.fill" -> "applelogo"
                                    .imageScale(.medium)
                                    .font(.title2)                          // 跟文字同尺寸，動態字級會一起放大
                                    .symbolRenderingMode(.monochrome)
                                    .foregroundStyle(.secondary)            // 讓 icon 不搶戲
                            Text("Ingredients")
                                .font(.title2)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .foregroundStyle(.primary)
                                .accessibilityAddTraits(.isHeader)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        
                        ForEach(item.ingredients.indices, id:\.self){ index in
                            HStack(spacing: 12) {
                                let ingredient = item.ingredients[index]
                                
                                KFImage(URL(string: ingredient.getMealImageLink()))
                                    .placeholder { RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)) }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 48)
                                    .padding(.top, 16)
                                    .padding(.bottom, 16)
                                    .padding(.leading, 16)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ingredient)
                                        .font(.body.weight(.semibold))
                                    let measure = index < item.measures.count ? item.measures[index] : ""
                                        Text(measure)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    
                                }
                                Spacer()
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16) // 👈 圓角
                                    .fill(Color.white)            // 👈 白底
                                    .shadow(radius: 1)            // 👈 輕微陰影（optional）
                            )
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                            
                        }
                    }
                    .padding(.leading, 8)
                    .padding(.trailing, 8)
                    // Watch Button
                    YoutubeRoundedButton(
                        title: "Watch Video", systemImage: "arrowtriangle.right.fill", link: item.youtubeLink
                    )
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGray6))
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// Reuse from earlier
private struct MetaChip: View {
    let text: String
    let systemImage: String
    var body: some View {
        Label { Text(text) } icon: { Image(systemName: systemImage) }
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.9)))
            .foregroundStyle(.black.opacity(0.85))
    }
}

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

                                if let metaText = buildMetaText(area: item.area, category: item.category) {
                                    MetaChip(text: metaText)
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

                    SectionCard(
                        header: CardSectionHeader(
                            systemImage: "doc.text",
                            title: "Description"
                        )
                    ) {
                        Text(item.description)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 16)

                    SectionCard(
                        header: CardSectionHeader(
                            systemImage: "info.circle",
                            title: "Instructions"
                        )
                    ) {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(item.instructions.indices, id: \.self) { num in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(num + 1).")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                    Text(item.instructions[num])
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                }

                                if num < item.instructions.count - 1 {
                                    Divider()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(alignment: .leading) {
                        // Ingredients
                        HStack(spacing: 8) {
                            Image(systemName: "leaf.fill")              // 修正 "apple.fill" -> "applelogo"
                                    .imageScale(.medium)
                                    .font(.title2)                          // 跟文字同尺寸，動態字級會一起放大
                                    .symbolRenderingMode(.monochrome)
                                    .foregroundStyle(.secondary)            // 讓 icon 不搶戲
                            Text("Ingredients")
                                .font(.title2)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .accessibilityAddTraits(.isHeader)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 0) {
                            ForEach(item.ingredients.indices, id:\.self) { index in
                                HStack(spacing: 12) {
                                    let ingredient = item.ingredients[index]

                                    KFImage(URL(string: ingredient.getMealImageLink()))
                                        .placeholder { RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)) }
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 48, height: 48)
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)

                                if index < item.ingredients.count - 1 {
                                    Divider()
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                    }
                    .padding(.horizontal, 16)
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
    var body: some View {
        Text(text)
            .font(.callout.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.white.opacity(0.9)))
        .foregroundStyle(.black.opacity(0.85))
    }
}

private func buildMetaText(area: String?, category: String?) -> String? {
    let areaText: String? = {
        guard let area, !area.isEmpty else {
            return nil
        }
        let flag = area.toFlagEmoji()
        if flag.isEmpty {
            return area
        }
        return "\(flag) \(area)"
    }()
    let categoryText: String? = {
        guard let category, !category.isEmpty else {
            return nil
        }
        return category
    }()

    switch (areaText, categoryText) {
    case let (.some(areaText), .some(categoryText)):
        return "\(areaText) • \(categoryText)"
    case let (.some(areaText), .none):
        return areaText
    case let (.none, .some(categoryText)):
        return categoryText
    case (.none, .none):
        return nil
    }
}

private struct CardSectionHeader: View {
    let systemImage: String
    let title: String
    var subtitle: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: systemImage)
                .imageScale(.medium)
                .font(.title2)
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityAddTraits(.isHeader)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SectionCard<Content: View>: View {
    let header: CardSectionHeader
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

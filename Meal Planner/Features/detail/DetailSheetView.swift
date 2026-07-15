//
//  DetailSheetView.swift
//  Meal Planner
//
//  Created by eric ho on 17/8/2025.
//
import SwiftUI
import Kingfisher
import UIKit

struct DetailSheetView: View {
    @ObservedObject var vm: DetailViewModel
    @State private var selectedContentTab: MealDetailContentTab = .instructions
    @State private var favoriteButtonScale = 1.0
    @State private var contentTabHeights: [MealDetailContentTab: CGFloat] = [:]

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
                        .overlay(alignment: .bottomTrailing) {
                            FavoriteHeaderButton(
                                isFavorite: item.isFavorite,
                                isSaving: vm.state.isSavingFavorite,
                                scale: favoriteButtonScale,
                                action: toggleFavorite
                            )
                            .padding(.trailing, 16)
                            .padding(.bottom, 16)
                        }
                        .onLongPressGesture {
                            print("my id is = " + item.id)
                        }

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
                            systemImage: selectedContentTab.systemImage,
                            title: "Recipe Details"
                        )
                    ) {
                        MealDetailTabbedContent(
                            item: item,
                            selectedTab: $selectedContentTab,
                            measuredHeights: $contentTabHeights
                        )
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

    private func toggleFavorite() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        withAnimation(.spring(response: 0.22, dampingFraction: 0.55)) {
            favoriteButtonScale = 1.18
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.26, dampingFraction: 0.62)) {
                favoriteButtonScale = 1.0
            }
        }

        vm.onIntent(.toggleFavorite)
    }
}

private enum MealDetailContentTab: String, CaseIterable, Identifiable {
    case instructions = "Instructions"
    case ingredients = "Ingredients"

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .instructions:
            return "info.circle"
        case .ingredients:
            return "leaf.fill"
        }
    }
}

private struct FavoriteHeaderButton: View {
    let isFavorite: Bool
    let isSaving: Bool
    let scale: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title3.weight(.bold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(isFavorite ? .red : .primary)
                .frame(width: 48, height: 48)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.22), radius: 10, y: 4)
                .scaleEffect(scale)
                .opacity(isSaving ? 0.65 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isSaving)
        .accessibilityIdentifier("detail.favoriteButton")
        .accessibilityLabel(isFavorite ? "Remove from favourites" : "Add to favourites")
        .accessibilityHint("Updates the recipe bookmark")
    }
}

private struct MealDetailTabbedContent: View {
    let item: UIRecipeItem
    @Binding var selectedTab: MealDetailContentTab
    @Binding var measuredHeights: [MealDetailContentTab: CGFloat]

    private var selectedContentHeight: CGFloat {
        max(measuredHeights[selectedTab] ?? 220, 220)
    }

    var body: some View {
        VStack(spacing: 14) {
            Picker("Recipe detail section", selection: $selectedTab) {
                ForEach(MealDetailContentTab.allCases) { tab in
                    Label(tab.rawValue, systemImage: tab.systemImage)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)

            TabView(selection: $selectedTab) {
                InstructionsTab(instructions: item.instructions)
                    .fixedSize(horizontal: false, vertical: true)
                    .readHeight(for: .instructions)
                    .tag(MealDetailContentTab.instructions)

                IngredientsTab(ingredients: item.ingredients, measures: item.measures)
                    .fixedSize(horizontal: false, vertical: true)
                    .readHeight(for: .ingredients)
                    .tag(MealDetailContentTab.ingredients)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: selectedContentHeight)
            .animation(.spring(response: 0.28, dampingFraction: 0.86), value: selectedContentHeight)
        }
        .onPreferenceChange(MealDetailTabHeightPreferenceKey.self) { measuredHeights = $0 }
    }
}

private struct InstructionsTab: View {
    let instructions: [String]

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(instructions.indices, id: \.self) { num in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(num + 1).")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(instructions[num])
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if num < instructions.count - 1 {
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 2)
    }
}

private struct IngredientsTab: View {
    let ingredients: [String]
    let measures: [String]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(ingredients.indices, id: \.self) { index in
                HStack(spacing: 12) {
                    let ingredient = ingredients[index]

                    KFImage(URL(string: ingredient.getMealImageLink()))
                        .placeholder { RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)) }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(ingredient)
                            .font(.body.weight(.semibold))
                        let measure = index < measures.count ? measures[index] : ""
                        Text(measure)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)

                if index < ingredients.count - 1 {
                    Divider()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGroupedBackground))
        )
    }
}

private struct MealDetailTabHeightPreferenceKey: PreferenceKey {
    static var defaultValue: [MealDetailContentTab: CGFloat] = [:]

    static func reduce(
        value: inout [MealDetailContentTab: CGFloat],
        nextValue: () -> [MealDetailContentTab: CGFloat]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

private extension View {
    func readHeight(for tab: MealDetailContentTab) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: MealDetailTabHeightPreferenceKey.self,
                    value: [tab: proxy.size.height]
                )
            }
        )
    }
}

// Reuse from earlier
private struct MetaChip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.headline.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .foregroundStyle(.primary)
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
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

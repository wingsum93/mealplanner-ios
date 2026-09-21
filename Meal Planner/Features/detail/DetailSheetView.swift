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
    let item: UIRecipeItem
    @EnvironmentObject private var appRouter: AppRouter
    @ObservedObject var vm: DetailViewModel
    let onTapIngredient: (String) -> Void
    @State private var selectedContentTab: MealDetailContentTab = .instructions
    @State private var favoriteButtonScale = 1.0

    var body: some View {
        let displayedItem = vm.state.item ?? item

        ScrollView {
            VStack(spacing: 16) {
                // Header image
                KFImage(displayedItem.thumbURL)
                    .placeholder {
                        Rectangle().fill(Color(.systemGray5))
                    }
                    .onFailureView {
                        ImageLoadFailureView(iconSize: 48)
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
                            Text(displayedItem.name)
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .lineLimit(2)
                                .shadow(radius: 4)

                            if let metaText = buildMetaText(area: displayedItem.area, category: displayedItem.category) {
                                MetaChip(text: metaText)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        FavoriteHeaderButton(
                            isFavorite: displayedItem.isFavorite,
                            isSaving: vm.state.isSavingFavorite,
                            scale: favoriteButtonScale,
                            action: toggleFavorite
                        )
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                    .overlay(alignment: .topTrailing) {
                        CloseSheetButton(action: closeSheet)
                            .padding(.top, 14)
                            .padding(.trailing, 16)
                    }
                    .onLongPressGesture {
                        print("my id is = " + displayedItem.id)
                    }

                SectionCard(
                    header: CardSectionHeader(
                        systemImage: "doc.text",
                        title: "Description"
                    )
                ) {
                    Text(displayedItem.description)
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
                        item: displayedItem,
                        selectedTab: $selectedContentTab,
                        onTapIngredient: onTapIngredient
                    )
                }
                .padding(.horizontal, 16)

                // Watch Button
                YoutubeRoundedButton(
                    title: "Watch Video", systemImage: "arrowtriangle.right.fill", link: displayedItem.youtubeLink
                )
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGray6))
        .accessibilityIdentifier("detail.sheet")
        .onAppear {
            vm.onIntent(.setItem(item))
        }
        .onDisappear {
            vm.onIntent(.dismiss)
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

    private func closeSheet() {
        appRouter.dismissSheet()
    }
}

private enum MealDetailContentTab: String, CaseIterable, Identifiable {
    case instructions = "Instructions"
    case ingredients = "Ingredients"

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .instructions:
            return "Instructions"
        case .ingredients:
            return "Ingredients"
        }
    }

    var systemImage: String {
        switch self {
        case .instructions:
            return "info.circle"
        case .ingredients:
            return "leaf.fill"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .instructions:
            return "detail.tab.instructions"
        case .ingredients:
            return "detail.tab.ingredients"
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

private struct CloseSheetButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.primary)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.18), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("detail.closeButton")
        .accessibilityLabel("Close recipe details")
    }
}

private struct MealDetailTabbedContent: View {
    let item: UIRecipeItem
    @Binding var selectedTab: MealDetailContentTab
    let onTapIngredient: (String) -> Void

    var body: some View {
        VStack(spacing: 14) {
            Picker("Recipe detail section", selection: $selectedTab) {
                ForEach(MealDetailContentTab.allCases) { tab in
                    Label(tab.title, systemImage: tab.systemImage)
                        .accessibilityIdentifier(tab.accessibilityIdentifier)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)

            Group {
                switch selectedTab {
                case .instructions:
                    InstructionsTab(instructions: item.instructions)
                case .ingredients:
                    IngredientsTab(
                        ingredients: item.ingredients,
                        measures: item.measures,
                        onTapIngredient: onTapIngredient
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct InstructionsTab: View {
    let instructions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
    let onTapIngredient: (String) -> Void

    var body: some View {
        VStack(spacing: 8) {
            ForEach(ingredients.indices, id: \.self) { index in
                Button {
                    onTapIngredient(ingredients[index])
                } label: {
                    IngredientRow(
                        ingredient: ingredients[index],
                        measure: index < measures.count ? measures[index] : ""
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("detail.ingredientChip.\(index)")
                .accessibilityLabel(ingredients[index])
                .accessibilityHint("Shows recipes with this ingredient")
            }
        }
    }
}

private struct IngredientRow: View {
    let ingredient: String
    let measure: String

    var body: some View {
        HStack(spacing: 12) {
            KFImage(URL(string: ingredient.getMealImageLink()))
                .placeholder {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.secondary.opacity(0.14))
                        .overlay {
                            Image(systemName: "leaf.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.primary.opacity(0.75))
                        }
                }
                .onFailureView {
                    ImageLoadFailureView(iconSize: 18)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.75), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(ingredient)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                if !measure.isEmpty {
                    Text(measure)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.secondary.opacity(0.12),
                            Color.primary.opacity(0.07),
                            Color(.systemBackground).opacity(0.86)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.primary.opacity(0.18),
                            Color.secondary.opacity(0.22)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.primary.opacity(0.06), radius: 6, x: 0, y: 3)
        .accessibilityElement(children: .combine)
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
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil

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
                if let subtitle {
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

//
//  HomeScreen.swift
//  Meal Planner
//
//  Created by eric ho on 10/8/2025.
//

import SwiftUI
import Kingfisher

struct HomeScreen: View {
    @ObservedObject var vm: FeatureViewModel
    let heroNamespace: Namespace.ID
    @EnvironmentObject private var appRouter: AppRouter

    var body: some View {
        ScrollView {
            Text("Recipes")
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .accessibilityAddTraits(.isHeader)

            searchEntry

            if isInitialHomeLoading {
                SkeletonHomePageView()
            } else {
                HomeContent(
                    home: vm.state.home,
                    ingredients: vm.state.ingredients.items,
                    onFeaturedTap: { appRouter.presentRecipeDetail($0) },
                    onAreaTap: { area in
                        appRouter.selectedTab = .recipe
                        vm.onIntent(.loadArea(area))
                        appRouter.push(.area(area))
                    },
                    onCategoryTap: { category in
                        appRouter.selectedTab = .recipe
                        vm.onIntent(.loadCategory(category))
                        appRouter.push(.category(category))
                    },
                    onIngredientListTap: {
                        appRouter.selectedTab = .recipe
                        appRouter.push(.ingredientList)
                    },
                    onIngredientTap: { ingredientName in
                        appRouter.selectedTab = .recipe
                        vm.onIntent(.loadIngredientMeals(ingredientName))
                        appRouter.push(.ingredient(ingredientName))
                    },
                    onRandomPickTap: { appRouter.presentRandomPick() },
                    onRecipeTap: { appRouter.presentRecipeDetail($0) }
                )
            }
        }
        .refreshable {
            vm.onIntent(.refreshHome)
        }
        .navigationTitle("Recipes")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var searchEntry: some View {
        SearchBar(placeholder: "Search recipes…") {
            appRouter.push(.search)
        }
        .searchMatchedTransitionSource(id: HeroSearchTransition.searchEntryID, in: heroNamespace)
        .accessibilityIdentifier("recipe.searchEntry")
        .background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: SearchEntryCenterPreferenceKey.self,
                    value: proxy.frame(in: .named(HeroSearchTransition.coordinateSpace)).center
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var isInitialHomeLoading: Bool {
        vm.state.home.phase == .loading
        && vm.state.home.featured == nil
        && vm.state.home.areas.isEmpty
        && vm.state.home.categories.isEmpty
        && vm.state.home.randomTen.isEmpty
        && vm.state.ingredients.items.isEmpty
    }
}

private struct HomeContent: View {
    let home: HomeState
    let ingredients: [Ingredient]
    let onFeaturedTap: (UIRecipeItem) -> Void
    let onAreaTap: (String) -> Void
    let onCategoryTap: (String) -> Void
    let onIngredientListTap: () -> Void
    let onIngredientTap: (String) -> Void
    let onRandomPickTap: () -> Void
    let onRecipeTap: (UIRecipeItem) -> Void

    var body: some View {
        let previewItems = Array(home.randomTen.prefix(3))
        let visibleIngredientCount = min(ingredients.count, 20)

        VStack(alignment: .leading, spacing: 16) {
            // 1) Featured random recipe
            if let featured = home.featured {
                Button {
                    onFeaturedTap(featured)
                } label: {
                    EditorialFeaturedRecipe(item: featured)
                        .accessibilityIdentifier("recipe.featuredRecipe")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("recipe.featuredRecipeButton")
                .padding(.horizontal, 16)
            }

            // 2) Areas horizontal
            CookbookSectionHeading("Areas")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(home.areas.indices, id: \.self) { index in
                        let area = home.areas[index]
                        Button {
                            onAreaTap(area)
                        } label: {
                            ImageSquareChip(text: area, imageLink: area.getAreaImageURL())
                                .contentShape(Rectangle())  // 明確 hit 區 = 整個 chip
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("recipe.areaChip.\(index)")
                    }
                }.padding(.horizontal, 16)
            }

            // 3) Categories horizontal
            CookbookSectionHeading("Categories")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(home.categories.indices, id: \.self) { index in
                        let cat = home.categories[index]
                        Button {
                            onCategoryTap(cat)
                        } label: {
                            ImageSquareChip(text: cat, imageLink: cat.mealCategoryImageLink)
                                .contentShape(Rectangle())  // 明確 hit 區 = 整個 chip
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("recipe.categoryChip.\(index)")
                    }
                }.padding(.horizontal, 16)
            }

            // 4) Ingredients horizontal
            if visibleIngredientCount > 0 {
                CookbookSectionHeading("Ingredients")
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        Button {
                            onIngredientListTap()
                        } label: {
                            IngredientBrowseCapsule(name: "", isSeeAll: true)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("See all ingredients")
                        .accessibilityIdentifier("recipe.ingredientsSeeAll")

                        ForEach(0..<visibleIngredientCount, id: \.self) { index in
                            let ingredient = ingredients[index]
                            Button {
                                onIngredientTap(ingredient.name)
                            } label: {
                                IngredientBrowseCapsule(name: ingredient.name)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("recipe.ingredientChip.\(index)")
                        }
                    }.padding(.horizontal, 16)
                }
                .accessibilityIdentifier("recipe.ingredientsScroll")
            }

            // 5) Random 10 horizontal
            CookbookSectionHeading("Discover")
            Button {
                onRandomPickTap()
            } label: {
                RandomPickFeatureCard(items: previewItems)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Random Pick")
            .accessibilityIdentifier("recipe.randomPickCard")
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(home.randomTen.indices, id: \.self) { index in
                        let item = home.randomTen[index]
                        Button { onRecipeTap(item) } label: {
                            RecipeCardSmall(item: item, width: 150)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("recipe.randomRecipeCard.\(index)")
                    }
                }.padding(.horizontal, 16)
            }
        }
    }
}

private struct RandomPickFeatureCard: View {
    let items: [UIRecipeItem]
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        HStack(spacing: 16) {
            iconBadge

            VStack(alignment: .leading, spacing: 8) {
                Text("Random Pick")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)

                Text("Swipe through 10 fresh recipe ideas.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            if !items.isEmpty {
                previewStack
            }

            Image(systemName: "chevron.right")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var iconBadge: some View {
        Image(systemName: "sparkles")
            .font(.title3.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(Color.accentColor)
            )
    }

    private var previewStack: some View {
        HStack(spacing: -10) {
            ForEach(items, id: \.id) { item in
                KFImage(item.thumbURL)
                    .placeholder {
                        Color.gray.opacity(0.35)
                    }
                    .onFailureView {
                        ImageLoadFailureView(iconSize: 16)
                    }
                    .setProcessor(
                        DownsamplingImageProcessor(
                            size: CGSize(width: 42 * displayScale, height: 42 * displayScale)
                        )
                    )
                    .scaleFactor(displayScale)
                    .cancelOnDisappear(true)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color(.systemBackground), lineWidth: 2)
                    )
            }
        }
        .accessibilityHidden(true)
    }
}

private struct SeeAllIngredientCard: View {
    var size: CGFloat = 88

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "chevron.right.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )

            Text("See all")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: size)
        }
        .frame(width: size)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("See all ingredients")
    }
}

private extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

// Local presentation keeps the shared recipe cards unchanged on other screens.
private struct EditorialFeaturedRecipe: View {
    let item: UIRecipeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KFImage(item.thumbURL)
                .placeholder { Color.secondary.opacity(0.12) }
                .onFailureView { ImageLoadFailureView() }
                .resizable()
                .scaledToFill()
                .frame(height: 240)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text("ON THE MENU")
                    .font(.caption.weight(.semibold))
                    .tracking(2)
                    .foregroundStyle(.secondary)
                Text(item.name)
                    .font(.system(.title, design: .serif, weight: .semibold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                if let area = item.area, !area.isEmpty {
                    Text(area).font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}

struct CookbookSectionHeading: View {
    let title: LocalizedStringKey

    init(_ title: LocalizedStringKey) { self.title = title }

    var body: some View {
        Text(title)
            .font(.system(.title2, design: .serif, weight: .semibold))
            .accessibilityAddTraits(.isHeader)
            .padding(.horizontal, 16)
            .padding(.top, 16)
    }
}

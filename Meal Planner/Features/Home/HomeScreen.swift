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
            searchEntry

            if isInitialHomeLoading {
                SkeletonHomePageView()
            } else {
                homeContent
            }
        }
        .navigationTitle("Recipes")
    }

    private var searchEntry: some View {
        SearchBar(placeholder: "Search recipes…") {
            appRouter.push(.search)
        }
        .searchMatchedTransitionSource(id: HeroSearchTransition.searchEntryID, in: heroNamespace)
        .accessibilityIdentifier("home.searchEntry")
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

    private var homeContent: some View {
        Group {
            // 1) Featured random recipe
            if let featured = vm.state.home.featured {
                RecipeHeroCard(item: featured)
                    .onTapGesture { appRouter.presentRecipeDetail(featured) }
                    .padding(.horizontal, 16)
            }

            // 2) Areas horizontal
            SectionHeader("Areas")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.state.home.areas, id: \.self) { area in
                        Button {
                            vm.onIntent(.loadArea(area))
                            appRouter.push(.area(area))
                        } label: {
                            ImageSquareChip(text: area, imageLink: area.getAreaImageURL())
                                .contentShape(Rectangle())  // 明確 hit 區 = 整個 chip
                        }
                        .buttonStyle(.plain)
                    }
                }.padding(.horizontal, 16)
            }

            // 3) Categories horizontal
            SectionHeader("Categories")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.state.home.categories, id: \.self) { cat in
                        Button {
                            vm.onIntent(.loadCategory(cat))
                            appRouter.push(.category(cat))
                        } label: {
                            ImageSquareChip(text: cat, imageLink: cat.mealCategoryImageLink)
                                .contentShape(Rectangle())  // 明確 hit 區 = 整個 chip
                        }
                        .buttonStyle(.plain)
                    }
                }.padding(.horizontal, 16)
            }

            // 4) Ingredients horizontal
            if !vm.state.ingredients.items.isEmpty {
                SectionHeader("Ingredients")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(vm.state.ingredients.items.prefix(20)) { ingredient in
                            Button {
                                vm.onIntent(.loadIngredientMeals(ingredient.name))
                                appRouter.push(.ingredient(ingredient.name))
                            } label: {
                                IngredientSquareCard(name: ingredient.name)
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            appRouter.push(.ingredientList)
                        } label: {
                            SeeAllIngredientCard()
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("home.ingredientsSeeAll")
                    }.padding(.horizontal, 16)
                }
            }

            // 5) Random 10 horizontal
            SectionHeader("Discover")
            Button {
                appRouter.presentRandomPick()
            } label: {
                RandomPickFeatureCard(items: Array(vm.state.home.randomTen.prefix(3)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Random Pick")
            .accessibilityIdentifier("home.randomPickCard")
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.state.home.randomTen, id: \.id) { item in
                        RecipeCardSmall(item: item, width: 150)
                            .onTapGesture { appRouter.presentRecipeDetail(item) }
                    }
                }.padding(.horizontal, 16)
            }
        }
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

private struct RandomPickFeatureCard: View {
    let items: [UIRecipeItem]

    var body: some View {
        HStack(spacing: 14) {
            iconBadge

            VStack(alignment: .leading, spacing: 6) {
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
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
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

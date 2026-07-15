//
//  RecipeMainPage.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI

struct RecipeMainPage: View {
    @StateObject var viewModel: FeatureViewModel
    @EnvironmentObject private var detailVM: DetailViewModel
    @EnvironmentObject private var favVM: FavouriteViewModel
    let heroNamespace: Namespace.ID
    @State private var searchRevealOrigin: CGPoint?
    
    var body: some View {
        NavigationStack(path: Binding(
            get: { viewModel.state.path },
            set: { viewModel.onIntent(.replacePath($0)) }
        )) {
            HomeScreen(vm: viewModel, heroNamespace: heroNamespace)
                .onPreferenceChange(SearchEntryCenterPreferenceKey.self) { origin in
                    searchRevealOrigin = origin
                }
                .navigationDestination(for: FeatureRoute.self) { route in
                    switch route {
                    case .area(let a):
                        TitleListScreen(
                            title: a,
                            items: viewModel.state.area.items,
                            onTapItem: {item in
                                print("Tapped id =", item.id)
                                detailVM.onIntent(.setItem(item))
                            }
                        )
                    case .category(let c):
                        TitleListScreen(
                            title: c,
                            items: viewModel.state.category.items,
                            onTapItem: {item in
                                print("Tapped id =", item.id)
                                detailVM.onIntent(.setItem(item))
                            }
                        )
                    case .search:
                        SearchScreen(
                            query: Binding(
                                get: { viewModel.state.search.query },
                                set: { viewModel.onIntent(.updateQuery($0)) }
                            ),
                            placeholder: "Search recipes…",
                            searchPhase: viewModel.state.search.phase,
                            searchResults: viewModel.state.search.results,
                            onCommit: {
                                viewModel.onIntent(.performSearch)
                            },
                            onClear: {
                                viewModel.onIntent(.updateQuery(""))
                                // vm.onIntent(.resetSearch)
                            },
                            onItemTap: { item in
                                detailVM.onIntent(.setItem(item))
                            },
                            onFavoriteToggle: { item, isFavorite in
                                viewModel.onIntent(.updateSearchFavorite(id: item.id, isFavorite: isFavorite))
                                favVM.onIntent(.toggleFavorite(item))
                            }
                        )
                        .navigationTransition(.zoom(sourceID: HeroSearchTransition.searchEntryID, in: heroNamespace))
                        .circularReveal(from: searchRevealOrigin)
                    case .randomPick:
                        RandomPickScreen(vm: viewModel)
                    
                    }
                }
                .task { // first load only once
                    if viewModel.state.home.phase == .idle {
                        viewModel.onIntent(.loadHome)
                    }
                }
        }
        .coordinateSpace(name: HeroSearchTransition.coordinateSpace)
    }
    
}

enum HeroSearchTransition {
    static let searchEntryID = "home.searchEntry.hero"
    static let coordinateSpace = "home.searchRevealSpace"
}

struct SearchEntryCenterPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint?

    static func reduce(value: inout CGPoint?, nextValue: () -> CGPoint?) {
        value = nextValue() ?? value
    }
}

private struct CircularRevealShape: Shape {
    var origin: CGPoint
    var radius: CGFloat

    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path(ellipseIn: CGRect(
            x: origin.x - radius,
            y: origin.y - radius,
            width: radius * 2,
            height: radius * 2
        ))
    }
}

private struct CircularRevealModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealProgress = 0.0

    let origin: CGPoint?

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let rect = proxy.frame(in: .named(HeroSearchTransition.coordinateSpace))
            let localOrigin = localRevealOrigin(in: rect)
            let maxRadius = revealRadius(from: localOrigin, in: proxy.size)

            content
                .clipShape(CircularRevealShape(
                    origin: localOrigin,
                    radius: maxRadius * revealProgress
                ))
                .onAppear {
                    guard !reduceMotion else {
                        revealProgress = 1
                        return
                    }

                    revealProgress = 0
                    withAnimation(.easeInOut(duration: 0.42)) {
                        revealProgress = 1
                    }
                }
        }
    }

    private func localRevealOrigin(in rect: CGRect) -> CGPoint {
        guard let origin else {
            return CGPoint(x: rect.width / 2, y: rect.height / 2)
        }

        return CGPoint(
            x: origin.x - rect.minX,
            y: origin.y - rect.minY
        )
    }

    private func revealRadius(from origin: CGPoint, in size: CGSize) -> CGFloat {
        let corners = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: size.width, y: 0),
            CGPoint(x: 0, y: size.height),
            CGPoint(x: size.width, y: size.height)
        ]

        return corners
            .map { hypot($0.x - origin.x, $0.y - origin.y) }
            .max() ?? 0
    }
}

extension View {
    func circularReveal(from origin: CGPoint?) -> some View {
        modifier(CircularRevealModifier(origin: origin))
    }
}

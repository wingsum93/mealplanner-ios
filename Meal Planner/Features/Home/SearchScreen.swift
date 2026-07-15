//
//  SearchScreen.swift
//  Meal Planner
//
//  Created by eric ho on 10/8/2025.
//
import SwiftUI

struct SearchScreen: View {
    @Binding var query: String
    var placeholder: String
    var searchPhase: Phase
    var searchResults: [UIRecipeItem]
    var onCommit: () -> Void
    var onClear: () -> Void
    var onItemTap: (UIRecipeItem) -> Void
    var onFavoriteToggle: (UIRecipeItem, Bool) -> Void

    init(
        query: Binding<String>,
        placeholder: String = "Search...",
        searchPhase: Phase,
        searchResults: [UIRecipeItem],
        onCommit: @escaping () -> Void = {},
        onClear: @escaping () -> Void = {},
        onItemTap: @escaping (UIRecipeItem) -> Void = { _ in },
        onFavoriteToggle: @escaping (UIRecipeItem, Bool) -> Void = { _, _ in }
    ) {
        self._query = query
        self.placeholder = placeholder
        self.searchPhase = searchPhase
        self.searchResults = searchResults
        self.onCommit = onCommit
        self.onClear = onClear
        self.onItemTap = onItemTap
        self.onFavoriteToggle = onFavoriteToggle
    }
    var body: some View {
        VStack(spacing: 0) {
            SearchField(
                text: $query,
                placeholder: placeholder,
                onCommit: onCommit,
                onClear: onClear
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)

            content
        }
        .accessibilityIdentifier("search.container")
        .navigationTitle("Search")
    }

    @ViewBuilder
    private var content: some View {
        switch searchPhase {
        case .idle:
            EmptySearchPlaceholder()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loading:
            SpiningCatLoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(x:0.7, y:0.7, anchor: .center)
        case .content:
            if searchResults.isEmpty {
                EmptyStateView(message: "No results")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(searchResults, id: \.id) { item in
                        SearchRecipeRow(item: item, showFavorite: true) { isFavorite in
                            onFavoriteToggle(item, isFavorite)
                        }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onItemTap(item)
                            }
                    }
                }
                .listStyle(.plain)
            }

        case .empty:
            EmptyStateView(message: "No results")
                .frame(maxWidth: .infinity)

        case .error(let msg):
            ErrorView(message: msg, onAction: onCommit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview("Content") {
    @Previewable @State var query = "chicken"
    @Previewable @State var results: [UIRecipeItem] = [
        UIRecipeItem.new(id: "1", name: "Grilled Chicken", thumbURL: URL(string: "https://https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg")),
        UIRecipeItem.new(id: "2", name: "Chicken Curry", thumbURL: URL(string: "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg"))
    ]

    SearchScreen(
        query: $query,
        searchPhase: .content,
        searchResults: results
    )
}

#Preview("Loading") {
    @Previewable @State var query = ""
    @Previewable @State var results: [UIRecipeItem] = []

    SearchScreen(
        query: $query,
        searchPhase: .loading,
        searchResults: results
    )
}

#Preview("Empty") {
    @Previewable @State var query = ""
    @Previewable @State var results: [UIRecipeItem] = []

    SearchScreen(
        query: $query,
        searchPhase: .empty,
        searchResults: results
    )
}
#Preview("Error") {
    @Previewable @State var query = ""
    @Previewable @State var results: [UIRecipeItem] = []

    SearchScreen(
        query: $query,
        searchPhase: .error("no s"),
        searchResults: results
    )
}
#Preview("Idle") {
    @Previewable @State var query = ""
    @Previewable @State var results: [UIRecipeItem] = []

    SearchScreen(
        query: $query,
        searchPhase: .idle,
        searchResults: results
    )
}

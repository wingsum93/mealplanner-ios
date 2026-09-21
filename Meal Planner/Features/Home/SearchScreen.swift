//
//  SearchScreen.swift
//  Meal Planner
//
//  Created by eric ho on 10/8/2025.
//
import SwiftUI

struct SearchScreen: View {
    @Binding var query: String
    var placeholder: LocalizedStringKey
    var searchPhase: LoadPhase
    var searchResults: [UIRecipeItem]
    var onCommit: () -> Void
    var onClear: () -> Void
    var onItemTap: (UIRecipeItem) -> Void
    var onFavoriteToggle: (UIRecipeItem, Bool) -> Void

    init(
        query: Binding<String>,
        placeholder: LocalizedStringKey = "Search...",
        searchPhase: LoadPhase,
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
            ZStack {
                EmptySearchPlaceholder()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier("search.idle")

        case .loading:
            ZStack {
                SpiningCatLoadingView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(x:0.7, y:0.7, anchor: .center)
                .accessibilityIdentifier("search.loading")
        case .content:
            if searchResults.isEmpty {
                ZStack {
                    EmptyStateView(message: "No results")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityIdentifier("search.empty")
            } else {
                List {
                    ForEach(Array(searchResults.enumerated()), id: \.element.id) { index, item in
                        SearchRecipeRow(item: item, showFavorite: true) { isFavorite in
                            onFavoriteToggle(item, isFavorite)
                        }
                            .accessibilityIdentifier("search.resultRow.\(index)")
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onItemTap(item)
                            }
                    }
                }
                .listStyle(.plain)
                .accessibilityIdentifier("search.results")
            }

        case .empty:
            ZStack {
                EmptyStateView(message: "No results")
            }
            .frame(maxWidth: .infinity)
                .accessibilityIdentifier("search.empty")

        case .error(let msg):
            ZStack {
                ErrorView(message: msg, onAction: onCommit)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier("search.error")
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

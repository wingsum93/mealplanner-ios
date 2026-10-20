//
//  MyListScreen.swift
//  Meal Planner
//
//  Created by eric ho on 22/9/2026.
//

import SwiftUI
import Kingfisher

struct MyListScreen: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject var vm: MyListViewModel
    @EnvironmentObject private var appRouter: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("My List")
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                Group {
                    if dynamicTypeSize >= .xxxLarge {
                        collectionPicker.pickerStyle(.menu)
                    } else {
                        collectionPicker.pickerStyle(.segmented)
                    }
                }
                .frame(minHeight: 44)
                .accessibilityIdentifier("myList.segment")
            }
            .padding(16)

            MyListContent(
                state: vm.state,
                onLoadList: { vm.onIntent(.loadList(vm.state.selectedList)) },
                onSelectArea: { vm.onIntent(.selectArea($0)) },
                onSelectCategory: { vm.onIntent(.selectCategory($0)) },
                onOpenRecipe: { appRouter.presentRecipeDetail($0) }
            )
        }
        .background(Color(.systemGray6))
        .navigationTitle("My List")
        .navigationBarTitleDisplayMode(.inline)
        .task { vm.onIntent(.loadList(vm.state.selectedList)) }
        .alert(
            "Unable to update your list",
            isPresented: Binding(
                get: { vm.state.errorMessage != nil },
                set: { if !$0 { vm.onIntent(.clearError) } }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.state.errorMessage ?? "")
        }
    }

    private var collectionPicker: some View {
        Picker("List", selection: Binding(
            get: { vm.state.selectedList },
            set: { vm.onIntent(.selectList($0)) }
        )) {
            ForEach(RecipeListType.allCases) { type in
                Text(type.title).tag(type)
            }
        }
    }

}

private struct MyListContent: View {
    let state: MyListState
    let onLoadList: () -> Void
    let onSelectArea: (String?) -> Void
    let onSelectCategory: (String?) -> Void
    let onOpenRecipe: (UIRecipeItem) -> Void

    var body: some View {
        if !state.items.isEmpty {
            MyListLoadedContent(
                state: state,
                onLoadList: onLoadList,
                onSelectArea: onSelectArea,
                onSelectCategory: onSelectCategory,
                onOpenRecipe: onOpenRecipe
            )
        } else {
            phaseView
        }
    }

    @ViewBuilder
    private var phaseView: some View {
        switch state.phase {
        case .idle, .loading:
            SpiningCatLoadingView(message: "Loading your list...")
                .accessibilityIdentifier("myList.loading")
        case .empty, .content:
            MyListEmptyView(emptyMessage: state.emptyMessage)
        case .error(let message):
            ErrorView(message: message) {
                onLoadList()
            }
            .accessibilityIdentifier("myList.error")
        }
    }
}

private struct MyListEmptyView: View {
    let emptyMessage: String

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "books.vertical")
                        .font(.system(.largeTitle, design: .serif))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    Text(emptyMessage)
                        .font(.system(.title2, design: .serif, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 48)
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("myList.empty")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MyListLoadedContent: View {
    let state: MyListState
    let onLoadList: () -> Void
    let onSelectArea: (String?) -> Void
    let onSelectCategory: (String?) -> Void
    let onOpenRecipe: (UIRecipeItem) -> Void

    var body: some View {
        let filteredItems = state.filteredItems

        VStack(spacing: 0) {
            if state.showsFilters {
                MyListFilters(
                    selectedArea: state.selectedArea,
                    selectedCategory: state.selectedCategory,
                    availableAreas: state.availableAreas,
                    availableCategories: state.availableCategories,
                    onSelectArea: onSelectArea,
                    onSelectCategory: onSelectCategory
                )
            }

            List {
                Text(filteredItems.count == 1 ? "1 recipe" : "\(filteredItems.count) recipes")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                if filteredItems.isEmpty {
                    ContentUnavailableView {
                        Label("No matching recipes", systemImage: "line.3.horizontal.decrease.circle")
                    } description: {
                        Text("Try clearing your filters to see your collection.")
                    } actions: {
                        Button("Clear filters") {
                            onSelectArea(nil)
                            onSelectCategory(nil)
                        }
                        .frame(minHeight: 44)
                    }
                    .listRowSeparator(.hidden)
                }
                ForEach(filteredItems, id: \.id) { item in
                    MyListRow(item: item) {
                        onOpenRecipe(item)
                    }
                        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                }
            }
            .accessibilityIdentifier("myList.list")
            .listStyle(.plain)
            .refreshable { onLoadList() }
        }
    }
}

private struct MyListFilters: View {
    let selectedArea: String?
    let selectedCategory: String?
    let availableAreas: [String]
    let availableCategories: [String]
    let onSelectArea: (String?) -> Void
    let onSelectCategory: (String?) -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 16) { filterControls }
            VStack(alignment: .leading, spacing: 8) { filterControls }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private var filterControls: some View {
        Picker("Area", selection: Binding(
            get: { selectedArea },
            set: onSelectArea
        )) {
            Text("All Areas").tag(String?.none)
            ForEach(availableAreas, id: \.self) { area in
                Text(area).tag(Optional(area))
            }
        }
        .pickerStyle(.menu)
        .frame(minHeight: 44)

        Picker("Category", selection: Binding(
            get: { selectedCategory },
            set: onSelectCategory
        )) {
            Text("All Categories").tag(String?.none)
            ForEach(availableCategories, id: \.self) { category in
                Text(category).tag(Optional(category))
            }
        }
        .pickerStyle(.menu)
        .frame(minHeight: 44)
    }
}

private struct MyListRow: View {
    let item: UIRecipeItem
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(alignment: .top, spacing: 16) {
                KFImage(item.thumbURL)
                    .placeholder { Color.secondary.opacity(0.12) }
                    .onFailureView { ImageLoadFailureView() }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.name)
                        .font(.system(.title3, design: .serif, weight: .semibold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text([item.area, item.category].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 88)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

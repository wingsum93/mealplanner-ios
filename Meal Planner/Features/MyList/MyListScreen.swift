//
//  MyListScreen.swift
//  Meal Planner
//
//  Created by eric ho on 22/9/2026.
//

import SwiftUI

struct MyListScreen: View {
    @EnvironmentObject var vm: MyListViewModel
    @EnvironmentObject private var appRouter: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            Picker("List", selection: Binding(
                get: { vm.state.selectedList },
                set: { vm.onIntent(.selectList($0)) }
            )) {
                ForEach(RecipeListType.allCases) { type in
                    Label(type.title, systemImage: type.systemImage)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .accessibilityIdentifier("myList.segment")

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
            Spacer()

            LottieView(animationName: "empty_bookmark", loopMode: .loop)
                .frame(width: 200, height: 200)
                .scaleEffect(0.3)

            Spacer().frame(height: 50)

            Text(emptyMessage)
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            Spacer(minLength: 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("myList.empty")
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
                ForEach(filteredItems, id: \.id) { item in
                    MyListRow(item: item) {
                        onOpenRecipe(item)
                    }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onOpenRecipe(item)
                        }
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
        HStack(spacing: 12) {
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

private struct MyListRow: View {
    let item: UIRecipeItem
    let onOpen: () -> Void

    var body: some View {
        RecipeListRow(item: item) {
            Button(action: onOpen) {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open \(item.name)")
        }
    }
}

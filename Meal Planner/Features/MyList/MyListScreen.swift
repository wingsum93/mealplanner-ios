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

            Group {
                if shouldShowContent {
                    contentView
                } else {
                    phaseView
                }
            }
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

    private var shouldShowContent: Bool {
        !vm.state.items.isEmpty
    }

    @ViewBuilder
    private var phaseView: some View {
        switch vm.state.phase {
        case .idle, .loading:
            SpiningCatLoadingView(message: "Loading your list...")
                .accessibilityIdentifier("myList.loading")
        case .empty, .content:
            emptyView
        case .error(let message):
            ErrorView(message: message) {
                vm.onIntent(.loadList(vm.state.selectedList))
            }
            .accessibilityIdentifier("myList.error")
        }
    }

    private var emptyView: some View {
        VStack {
            Spacer()

            LottieView(animationName: "empty_bookmark", loopMode: .loop)
                .frame(width: 200, height: 200)
                .scaleEffect(0.3)

            Spacer().frame(height: 50)

            Text(vm.state.emptyMessage)
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

    private var contentView: some View {
        VStack(spacing: 0) {
            if vm.state.showsFilters {
                HStack(spacing: 12) {
                    Picker("Area", selection: Binding(
                        get: { vm.state.selectedArea },
                        set: { vm.onIntent(.selectArea($0)) }
                    )) {
                        Text("All Areas").tag(String?.none)
                        ForEach(vm.state.availableAreas, id: \.self) { area in
                            Text(area).tag(Optional(area))
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Category", selection: Binding(
                        get: { vm.state.selectedCategory },
                        set: { vm.onIntent(.selectCategory($0)) }
                    )) {
                        Text("All Categories").tag(String?.none)
                        ForEach(vm.state.availableCategories, id: \.self) { category in
                            Text(category).tag(Optional(category))
                        }
                    }
                    .pickerStyle(.menu)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }

            List {
                ForEach(vm.state.filteredItems, id: \.id) { item in
                    row(for: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appRouter.presentRecipeDetail(item)
                        }
                }
            }
            .accessibilityIdentifier("myList.list")
            .listStyle(.plain)
            .refreshable { vm.onIntent(.loadList(vm.state.selectedList)) }
        }
    }

    @ViewBuilder
    private func row(for item: UIRecipeItem) -> some View {
        RecipeListRow(item: item) {
            Button {
                appRouter.presentRecipeDetail(item)
            } label: {
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

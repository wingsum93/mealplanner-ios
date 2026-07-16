//
//  FavouriteScreen.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI

struct FavouriteScreen :View {
    @EnvironmentObject var vm: FavouriteViewModel
    @EnvironmentObject private var appRouter: AppRouter
    
    var body: some View {
        Group {
            if shouldShowContent {
                contentView
            } else {
                phaseView
            }
        }
        .background(Color(.systemGray6)) // base screen background
        .navigationTitle("Favourites")
        .task { vm.onIntent(.loadFavorites) }
        .alert(
            "Unable to update favourites",
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
            SpiningCatLoadingView(message: "Loading favourites...")
                .accessibilityIdentifier("favourite.loading")
        case .empty, .content:
            emptyView
        case .error(let message):
            ErrorView(message: message) {
                vm.onIntent(.loadFavorites)
            }
            .accessibilityIdentifier("favourite.error")
        }
    }

    private var emptyView: some View {
        VStack {
            Spacer()

            LottieView(animationName: "empty_bookmark", loopMode: .loop)
                .frame(width: 200, height: 200)
                .scaleEffect(0.3)

            Spacer().frame(height: 50)

            Text("empty_bookmark_message")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            Spacer(minLength: 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("favourite.empty")
    }

    private var contentView: some View {
        VStack(spacing: 0) {
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
            .padding(.vertical, 12)

            List {
                ForEach(vm.state.filteredItems, id: \.id) { item in
                    SearchRecipeRow(item: item, showFavorite: true) { _ in
                        vm.onIntent(.toggleFavorite(item))
                    }
                    .onTapGesture {
                        appRouter.presentRecipeDetail(item)
                    }
                }
            }
            .accessibilityIdentifier("favourite.list")
            .listStyle(.plain)
            .refreshable { vm.onIntent(.loadFavorites) }
        }
    }
}

//
//  SearchScreen.swift
//  Meal Planner
//
//  Created by eric ho on 10/8/2025.
//
import SwiftUI

struct SearchScreen: View {
    @ObservedObject var vm: FeatureViewModel

    var body: some View {
        VStack(spacing: 0) {
            SearchField(
                text: Binding(
                    get: { vm.state.search.query },
                    set: { vm.onIntent(.updateQuery($0)) }
                ),
                placeholder: "Search recipes…",
                onCommit: {
                    vm.onIntent(.performSearch)
                },
                onClear: {
                    // 清空文本 & 可選地重置結果（視乎你嘅UX）
                    vm.onIntent(.updateQuery(""))
                    // 如果想清空列表/回到 idle：
                    // vm.onIntent(.resetSearch)
                }
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)

            content
        }
        .navigationTitle("Search")
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state.search.phase {
        case .idle:
            EmptySearchPlaceholder()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loading:
            SkeletonSearchListView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .content:
            List {
                ForEach(vm.state.search.results, id: \.id) { item in
                    SearchRecipeRow(item: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.onIntent(.goToDetail(item.id))
                        }
                }
            }
            .listStyle(.plain)

        case .empty:
            EmptyStateView(message: "No results")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .error(let msg):
            ErrorView(message: msg) {
                vm.onIntent(.performSearch)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}




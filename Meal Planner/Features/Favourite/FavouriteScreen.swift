//
//  FavouriteScreen.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//

import SwiftUI

struct FavouriteScreen :View {
    @EnvironmentObject var vm: FavouriteViewModel
    @EnvironmentObject var detailVM: DetailViewModel
    
    var body: some View {
        Group {
            if vm.favoriteItems.isEmpty {
                // Empty state with big Lottie
                VStack {
                    Spacer()
                    
                    LottieView(animationName: "empty_bookmark", loopMode: .loop)
                        .frame(width: 200, height: 200)
                        .scaleEffect(0.3)
                    
                    Spacer().frame(height: 50)   // 想要的間距
                    
                    Text("empty_bookmark_message")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32) // 距離底部
                    Spacer(minLength: 32)        // 底部留白
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)


            } else {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Picker("Area", selection: $vm.selectedArea) {
                            Text("All Areas").tag(String?.none)
                            ForEach(vm.availableAreas, id: \.self) { area in
                                Text(area).tag(Optional(area))
                            }
                        }
                        .pickerStyle(.menu)

                        Picker("Category", selection: $vm.selectedCategory) {
                            Text("All Categories").tag(String?.none)
                            ForEach(vm.availableCategories, id: \.self) { category in
                                Text(category).tag(Optional(category))
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    List {
                        ForEach(vm.filteredFavoriteItems, id: \.id) { item in
                            SearchRecipeRow(item: item, showFavorite: true) { _ in
                                vm.toggleFavorite(item)
                            }
                            .onTapGesture {
                                detailVM.onIntent(.setItem(item))
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable { vm.loadFavorites() }
                }
            }
        }
        .background(Color(.systemGray6)) // base screen background
        .navigationTitle("Favourites")
        .task { vm.loadFavorites() }
    }
}

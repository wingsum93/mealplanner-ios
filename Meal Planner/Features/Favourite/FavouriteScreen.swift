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
                List {
                    ForEach(vm.favoriteItems, id: \.id) { item in
                        SearchRecipeRow(item: item, showFavorite: true) { newFav in
                            //                    vm.toggleFavorite(item)
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
        .background(Color(.systemGray6)) // base screen background
        .navigationTitle("Favourites")
        .task { vm.loadFavorites() }
        
        .navigationTitle("Favourites")
        
        
    }
}

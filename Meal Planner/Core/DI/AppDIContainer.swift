//
//  DIContainer.swift
//  Meal Planner
//
//  Created by eric ho on 5/8/2025.
//
import SwiftData
import Foundation

@MainActor
final class AppDIContainer {
    
    let modelContext: ModelContext
    let networkClient: NetworkClient
    
    // MARK: - Data Sources
    private let _recipeRemoteDataSource: RecipeRemoteDataSource
    private let _recipeLocalDataSource: RecipeLocalDataSource
    
    // MARK: - Repository
    private let _recipeRepository: RecipeRepository
    
    // Designated init with full overrides (great for tests/previews)
    init(
        modelContext: ModelContext,
        networkClient: NetworkClient = AlamofireNetworkClient(),
        recipeRemoteDataSource: RecipeRemoteDataSource? = nil,
        recipeLocalDataSource: RecipeLocalDataSource? = nil,
        recipeRepository: RecipeRepository? = nil
    ) {
        self.modelContext = modelContext
        self.networkClient = networkClient
        
        // Build graph (no singletons or hidden deps)
        let remote = recipeRemoteDataSource ?? RecipeRemoteDataSourceImpl (networkClient)
        let local  = recipeLocalDataSource  ?? RecipeLocalDataSourceImpl(context: modelContext)
        let repo   = recipeRepository       ?? RecipeRepositoryImpl(remote: remote, local: local)
        
        self._recipeRemoteDataSource = remote
        self._recipeLocalDataSource  = local
        self._recipeRepository       = repo
    }
    
    // Expose read‑only if you want
    var recipeRepository: RecipeRepository { _recipeRepository }
    
    // MARK: - ViewModels
    func makeHomeViewModel() -> HomeViewModel {
        // HomeViewModel is typically @MainActor, so creating it here is safe.
        HomeViewModel(repository: _recipeRepository)
    }
}

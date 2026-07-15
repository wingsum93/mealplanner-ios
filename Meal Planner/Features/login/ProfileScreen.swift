//
//  ProfileScreen.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI

struct ProfileScreen:View{
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    let onLoginBtnClicked:() -> Void
    
    init(
        authViewModel: AuthViewModel,
        settingsViewModel: SettingsViewModel,
        _ onLoginBtnClicked:@escaping ()->Void = {}
    ) {
        self.authViewModel = authViewModel
        self.settingsViewModel = settingsViewModel
        self.onLoginBtnClicked = onLoginBtnClicked
    }
    
    // MARK: - Convenience initializer for preview
    init(isLoggedIn: Bool = false) {
        let mockVM = AuthViewModel(localDataSource: MockLoginLocalDataSource(loggedIn: isLoggedIn))
        let mockSettingsVM = SettingsViewModel(localDataSource: MockRecipeLocalDataSource())
        self.init(authViewModel: mockVM, settingsViewModel: mockSettingsVM)
    }
    
    var body: some View{
        SettingsScreen(
            isLoggedIn: authViewModel.state.isLoggedIn,
            settingsViewModel: settingsViewModel,
            onLogin: onLoginBtnClicked,
            onLogout: { _authViewModel.wrappedValue.onIntent(.logout) }
        )
        .onAppear {
            authViewModel.onIntent(.load)
        }
    }
}

#Preview("Logged Out") {
    ProfileScreen(isLoggedIn: false)
}

#Preview("Logged In") {
    ProfileScreen(isLoggedIn: true)
}

private struct MockRecipeLocalDataSource: RecipeLocalDataSource {
    func saveRecipe(_ item: RecipeEntity) throws { }
    func getRecipeById(_ id: Int64) throws -> RecipeEntity? { nil }
    func getAllCategories() throws -> [String] { [] }
    func saveAllCategories(_ categories: [String]) throws { }
    func getAllAreas() throws -> [String] { [] }
    func saveAllAreas(_ areas: [String]) throws { }
    func getAllIngredients() throws -> [IngredientEntity] { [] }
    func saveAllIngredients(_ ingredients: [IngredientEntity]) throws { }
    func updateFavorite(id: Int64, isFavorite: Bool) throws { }
    func isFavourite(id: Int64) -> Bool { false }
    func getAllFavoriteRecipes() throws -> [RecipeEntity] { [] }
    func clearCachedRecipes() throws { }
    func resetFavorites() throws { }
}

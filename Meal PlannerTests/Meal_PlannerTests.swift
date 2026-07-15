//
//  Meal_PlannerTests.swift
//  Meal PlannerTests
//
//  Created by eric ho on 3/8/2025.
//

import Testing
import Foundation
@testable import Meal_Planner

struct Meal_PlannerTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @MainActor
    @Test func staleSearchCompletionDoesNotOverwriteCurrentQuery() async throws {
        let repository = SearchRaceRecipeRepository()
        let viewModel = FeatureViewModel(repository: repository)

        viewModel.onIntent(.updateQuery("slow"))
        viewModel.onIntent(.performSearch)

        try await Task.sleep(nanoseconds: 550_000_000)

        viewModel.onIntent(.updateQuery("fast"))
        viewModel.onIntent(.performSearch)

        try await Task.sleep(nanoseconds: 700_000_000)

        #expect(viewModel.state.search.query == "fast")
        #expect(viewModel.state.search.results.map(\.name) == ["fast result"])
    }

    @MainActor
    @Test func emptySearchQueryResetsSearchState() async throws {
        let viewModel = FeatureViewModel(repository: SearchRaceRecipeRepository())

        viewModel.onIntent(.updateQuery("chicken"))
        viewModel.onIntent(.performSearch)
        try await Task.sleep(nanoseconds: 600_000_000)

        viewModel.onIntent(.updateQuery(""))
        viewModel.onIntent(.performSearch)

        #expect(viewModel.state.search.query == "")
        #expect(viewModel.state.search.phase == .idle)
        #expect(viewModel.state.search.results.isEmpty)
    }

    @MainActor
    @Test func oneCharacterSearchQueryDoesNotCallRepository() async throws {
        let repository = DebouncedSearchRecipeRepository()
        let viewModel = FeatureViewModel(repository: repository)

        viewModel.onIntent(.updateQuery("c"))

        try await Task.sleep(nanoseconds: 600_000_000)

        #expect(repository.searchedKeywords.isEmpty)
        #expect(viewModel.state.search.query == "c")
        #expect(viewModel.state.search.phase == .idle)
        #expect(viewModel.state.search.results.isEmpty)
    }

    @MainActor
    @Test func twoCharacterSearchQueryWaitsForDebounceBeforeCallingRepository() async throws {
        let repository = DebouncedSearchRecipeRepository()
        let viewModel = FeatureViewModel(repository: repository)

        viewModel.onIntent(.updateQuery("ch"))
        try await Task.sleep(nanoseconds: 300_000_000)

        #expect(repository.searchedKeywords.isEmpty)

        try await Task.sleep(nanoseconds: 300_000_000)

        #expect(repository.searchedKeywords == ["ch"])
        #expect(viewModel.state.search.results.map(\.name) == ["ch result"])
    }

    @MainActor
    @Test func newSearchInputCancelsPendingDebouncedQuery() async throws {
        let repository = DebouncedSearchRecipeRepository()
        let viewModel = FeatureViewModel(repository: repository)

        viewModel.onIntent(.updateQuery("ch"))
        try await Task.sleep(nanoseconds: 250_000_000)
        viewModel.onIntent(.updateQuery("chi"))

        try await Task.sleep(nanoseconds: 650_000_000)

        #expect(repository.searchedKeywords == ["chi"])
        #expect(viewModel.state.search.results.map(\.name) == ["chi result"])
    }

    @MainActor
    @Test func featureNavigationPathCanBeReplacedByIntent() {
        let viewModel = FeatureViewModel(repository: SearchRaceRecipeRepository())

        viewModel.onIntent(.goToSearch)
        #expect(viewModel.state.path == [.search])

        viewModel.onIntent(.replacePath([.area("Canadian")]))
        #expect(viewModel.state.path == [.area("Canadian")])
    }

    @MainActor
    @Test func randomPickItemsUpdateThroughIntent() {
        let viewModel = FeatureViewModel(repository: SearchRaceRecipeRepository())
        let items = [UIRecipeItem.new(id: "1", name: "One")]

        viewModel.onIntent(.updateRandomPickItems(items))

        #expect(viewModel.state.randomPick.items == items)
        #expect(viewModel.state.randomPick.phase == .content)
    }

    @Test func favouriteStateDerivesFiltersAndAvailableOptions() {
        var state = FavouriteState(items: [
            UIRecipeItem.new(id: "1", name: "A", area: "Thai", category: "Seafood"),
            UIRecipeItem.new(id: "2", name: "B", area: "Thai", category: "Dessert"),
            UIRecipeItem.new(id: "3", name: "C", area: "Canadian", category: "Seafood")
        ])

        #expect(state.availableAreas == ["Canadian", "Thai"])
        #expect(state.availableCategories == ["Dessert", "Seafood"])
        #expect(state.filteredItems.map(\.id) == ["1", "2", "3"])

        state.selectedArea = "Thai"
        state.selectedCategory = "Seafood"

        #expect(state.filteredItems.map(\.id) == ["1"])
    }

    @Test func authStateCanSubmitRequiresCredentialsAndIdleSubmitState() {
        #expect(AuthState().canSubmit == false)
        #expect(AuthState(email: "eric", password: "test").canSubmit)
        #expect(AuthState(email: "eric", password: "test", isLoggingIn: true).canSubmit == false)
    }

    @Test func detailStatePresentationFollowsSelectedItem() {
        #expect(DetailState().isPresented == false)
        #expect(DetailState(item: UIRecipeItem.new(id: "1", name: "Recipe")).isPresented)
    }

    @Test func loadPhaseEqualityIncludesErrorMessage() {
        #expect(LoadPhase.error("Search failed.") == .error("Search failed."))
        #expect(LoadPhase.error("Search failed.") != .error("Failed to load favourites."))
    }

    @MainActor
    @Test func authValidatesRequiredFieldsAndResetsForm() async throws {
        let viewModel = AuthViewModel(localDataSource: AuthLocalDataSourceSpy())

        viewModel.onIntent(.submitLogin)
        #expect(viewModel.state.loginErrorMessage == "Email is required")

        viewModel.onIntent(.updateEmail("eric"))
        viewModel.onIntent(.submitLogin)
        #expect(viewModel.state.loginErrorMessage == "Password is required")

        viewModel.onIntent(.updatePassword("test"))
        viewModel.onIntent(.togglePasswordVisibility)
        viewModel.onIntent(.resetLoginForm)

        #expect(viewModel.state.email == "")
        #expect(viewModel.state.password == "")
        #expect(viewModel.state.showPassword == false)
        #expect(viewModel.state.loginErrorMessage == nil)
    }

    @MainActor
    @Test func authHandlesFailedAndSuccessfulLogin() async throws {
        let localDataSource = AuthLocalDataSourceSpy(loginResult: false)
        let viewModel = AuthViewModel(localDataSource: localDataSource)

        viewModel.onIntent(.updateEmail("eric"))
        viewModel.onIntent(.updatePassword("wrong"))
        viewModel.onIntent(.submitLogin)
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.state.isLoggedIn == false)
        #expect(viewModel.state.loginErrorMessage == "Invalid email or password")

        localDataSource.loginResult = true
        viewModel.onIntent(.updatePassword("test"))
        viewModel.onIntent(.submitLogin)
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.state.isLoggedIn)
        #expect(localDataSource.loggedIn)

        viewModel.onIntent(.logout)
        #expect(viewModel.state.isLoggedIn == false)
        #expect(localDataSource.loggedIn == false)
    }

    @MainActor
    @Test func favouriteLoadsFiltersAndTogglesWithRollback() async throws {
        let favorite = makeRecipe(id: 1, title: "Fav", area: "Thai", category: "Seafood", isFavorite: true)
        let repository = FavoriteRecipeRepository(favorites: [favorite])
        let viewModel = FavouriteViewModel(repository: repository)

        viewModel.onIntent(.loadFavorites)
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.state.items.map(\.id) == ["1"])
        #expect(viewModel.state.availableAreas == ["Thai"])
        #expect(viewModel.state.availableCategories == ["Seafood"])

        viewModel.onIntent(.selectArea("Thai"))
        viewModel.onIntent(.selectCategory("Seafood"))
        #expect(viewModel.state.filteredItems.count == 1)

        viewModel.onIntent(.toggleFavorite(favorite.toUI()))
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(viewModel.state.items.isEmpty)

        repository.shouldFailUpdate = true
        let nonFavorite = makeRecipe(id: 2, title: "New", isFavorite: false).toUI()
        viewModel.onIntent(.toggleFavorite(nonFavorite))
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.state.items.contains(where: { $0.id == "2" }) == false)
        #expect(viewModel.state.errorMessage == "Failed to update favourite. Please try again.")
    }

    @MainActor
    @Test func detailToggleFavoriteRollsBackOnFailure() async throws {
        let repository = FavoriteRecipeRepository()
        repository.shouldFailUpdate = true
        let viewModel = DetailViewModel(repository: repository)
        let item = makeRecipe(id: 7, title: "Detail", isFavorite: false).toUI()

        viewModel.onIntent(.setItem(item))
        viewModel.onIntent(.toggleFavorite)

        #expect(viewModel.state.item?.isFavorite == true)
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.state.item?.isFavorite == false)
        #expect(viewModel.state.isSavingFavorite == false)
        #expect(viewModel.state.errorMessage == "Failed to update favourite. Please try again.")
    }

    @MainActor
    @Test func settingsReportsAndClearsActionErrors() {
        let localDataSource = SettingsLocalDataSourceSpy()
        localDataSource.error = TestError.expected
        let viewModel = SettingsViewModel(localDataSource: localDataSource)

        viewModel.onIntent(.perform(.clearCachedRecipes))
        #expect(viewModel.state.errorMessage == TestError.expected.localizedDescription)

        viewModel.onIntent(.clearError)
        #expect(viewModel.state.errorMessage == nil)
    }
}

private final class SearchRaceRecipeRepository: RecipeRepository {
    func searchByName(_ keyword: String) async throws -> [RecipeItem] {
        if keyword == "slow" {
            await delayIgnoringCancellation(seconds: 0.35)
        } else {
            await delayIgnoringCancellation(seconds: 0.01)
        }

        return [recipe(id: keyword == "slow" ? 1 : 2, title: "\(keyword) result")]
    }

    func getAllIngredients() async throws -> [Ingredient] { [] }
    func getAllCategory() async throws -> [String] { [] }
    func getAllArea() async throws -> [String] { [] }
    func getBySingleIngredient(_ name: String) async throws -> [RecipeItem] { [] }
    func getByCategory(_ category: String) async throws -> [RecipeItem] { [] }
    func getByArea(_ area: String) async throws -> [RecipeItem] { [] }
    func getRecipeDetail(id: String) async throws -> RecipeItem { recipe(id: Int64(id) ?? 0, title: "detail") }
    func getRandomRecipe() async throws -> RecipeItem { recipe(id: 99, title: "random") }
    func getRandom10Recipe() async throws -> [RecipeItem] { [] }
    func saveRecipe(_ item: RecipeItem) throws {}
    func updateFavorite(id: Int64, isFavorite: Bool) throws {}
    func isFavourite(id: Int64) -> Bool { false }
    func getAllFavoriteRecipes() throws -> [RecipeItem] { [] }

    private func delayIgnoringCancellation(seconds: TimeInterval) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + seconds) {
                continuation.resume()
            }
        }
    }

    private func recipe(id: Int64, title: String) -> RecipeItem {
        makeRecipe(id: id, title: title)
    }
}

private final class DebouncedSearchRecipeRepository: RecipeRepository {
    private let queue = DispatchQueue(label: "DebouncedSearchRecipeRepository.queue")
    private var _searchedKeywords: [String] = []

    var searchedKeywords: [String] {
        queue.sync { _searchedKeywords }
    }

    func searchByName(_ keyword: String) async throws -> [RecipeItem] {
        let callCount = queue.sync {
            _searchedKeywords.append(keyword)
            return _searchedKeywords.count
        }

        return [makeRecipe(id: Int64(callCount), title: "\(keyword) result")]
    }

    func getAllIngredients() async throws -> [Ingredient] { [] }
    func getAllCategory() async throws -> [String] { [] }
    func getAllArea() async throws -> [String] { [] }
    func getBySingleIngredient(_ name: String) async throws -> [RecipeItem] { [] }
    func getByCategory(_ category: String) async throws -> [RecipeItem] { [] }
    func getByArea(_ area: String) async throws -> [RecipeItem] { [] }
    func getRecipeDetail(id: String) async throws -> RecipeItem { makeRecipe(id: Int64(id) ?? 0, title: "detail") }
    func getRandomRecipe() async throws -> RecipeItem { makeRecipe(id: 99, title: "random") }
    func getRandom10Recipe() async throws -> [RecipeItem] { [] }
    func saveRecipe(_ item: RecipeItem) throws {}
    func updateFavorite(id: Int64, isFavorite: Bool) throws {}
    func isFavourite(id: Int64) -> Bool { false }
    func getAllFavoriteRecipes() throws -> [RecipeItem] { [] }
}

private final class AuthLocalDataSourceSpy: LoginLocalDataSource {
    var loginResult: Bool
    var loggedIn: Bool

    init(loginResult: Bool = true, loggedIn: Bool = false) {
        self.loginResult = loginResult
        self.loggedIn = loggedIn
    }

    func login(username: String, password: String) async -> Bool {
        loginResult
    }

    func isLoggedIn() -> Bool {
        loggedIn
    }

    func setLoggedIn(_ status: Bool) {
        loggedIn = status
    }

    func logout() {
        loggedIn = false
    }
}

private final class FavoriteRecipeRepository: RecipeRepository {
    var favorites: [RecipeItem]
    var shouldFailUpdate = false

    init(favorites: [RecipeItem] = []) {
        self.favorites = favorites
    }

    func updateFavorite(id: Int64, isFavorite: Bool) throws {
        if shouldFailUpdate {
            throw TestError.expected
        }

        if let index = favorites.firstIndex(where: { $0.id == id }) {
            favorites[index] = favorites[index].with(isFavorite: isFavorite)
            if !isFavorite {
                favorites.remove(at: index)
            }
        }
    }

    func saveRecipe(_ item: RecipeItem) throws {
        if let index = favorites.firstIndex(where: { $0.id == item.id }) {
            favorites[index] = item
        } else {
            favorites.append(item)
        }
    }

    func getAllFavoriteRecipes() throws -> [RecipeItem] {
        favorites.filter(\.isFavorite)
    }

    func getAllIngredients() async throws -> [Ingredient] { [] }
    func getAllCategory() async throws -> [String] { [] }
    func getAllArea() async throws -> [String] { [] }
    func getBySingleIngredient(_ name: String) async throws -> [RecipeItem] { [] }
    func getByCategory(_ category: String) async throws -> [RecipeItem] { [] }
    func getByArea(_ area: String) async throws -> [RecipeItem] { [] }
    func searchByName(_ keyword: String) async throws -> [RecipeItem] { [] }
    func getRecipeDetail(id: String) async throws -> RecipeItem { makeRecipe(id: Int64(id) ?? 0, title: "detail") }
    func getRandomRecipe() async throws -> RecipeItem { makeRecipe(id: 99, title: "random") }
    func getRandom10Recipe() async throws -> [RecipeItem] { [] }
    func isFavourite(id: Int64) -> Bool { favorites.contains { $0.id == id && $0.isFavorite } }
}

private final class SettingsLocalDataSourceSpy: RecipeLocalDataSource {
    var error: Error?

    func clearCachedRecipes() throws {
        if let error { throw error }
    }

    func resetFavorites() throws {
        if let error { throw error }
    }

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
}

private enum TestError: LocalizedError {
    case expected

    var errorDescription: String? {
        switch self {
        case .expected:
            return "Expected failure"
        }
    }
}

private extension RecipeItem {
    func with(isFavorite: Bool) -> RecipeItem {
        RecipeItem(
            id: id,
            title: title,
            description: description,
            category: category,
            area: area,
            imageUrl: imageUrl,
            youtubeLink: youtubeLink,
            ingredients: ingredients,
            measures: measures,
            instructions: instructions,
            tags: tags,
            isFavorite: isFavorite
        )
    }
}

private func makeRecipe(
    id: Int64,
    title: String,
    area: String = "Area",
    category: String = "Category",
    isFavorite: Bool = false
) -> RecipeItem {
    RecipeItem(
        id: id,
        title: title,
        description: "Description",
        category: category,
        area: area,
        imageUrl: "",
        youtubeLink: "",
        ingredients: [],
        measures: [],
        instructions: [],
        tags: [],
        isFavorite: isFavorite
    )
}

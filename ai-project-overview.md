ai-project-overview.md
📌 Project Overview
This is a SwiftUI + SwiftData iOS app that follows an MVI (Model-View-Intent) architecture with Dependency Injection (DI) for testability and modularity.
The app is a Recipe browsing app powered by TheMealDB API and supports local caching via SwiftData & UserDefaults.

🏗 Architecture
Layers
Presentation Layer

SwiftUI Views (HomeScreen, ProfileScreen, RecipeMainPage, LoadedHomePageView, etc.)

ViewModels following MVI (HomeViewModel, SettingsViewModel)

HomeScreenState / SettingsState to hold UI state

Intent enums to trigger actions (HomeIntent, SettingsIntent)

Domain Layer

Domain models:
RecipeItem, Ingredient, UIRecipeItem (UI-specific mapping model)

Mapper extensions for:

DTO → Domain

Domain → Entity

Entity → Domain

Data Layer

Repository Pattern:

RecipeRepository protocol

RecipeRepositoryImpl implements fetching from Remote and Local

Data Sources:

RecipeRemoteDataSource + RecipeRemoteDataSourceImpl (Alamofire + NetworkClient)

RecipeLocalDataSource + RecipeLocalDataSourceImpl (SwiftData + UserDefaults)

Entities (@Model for SwiftData):

RecipeEntity

IngredientEntity

DTO Models for API responses:

RecipeItemDto

IngredientDto

Core / Shared

NetworkClient — reusable async/await network calls

PersistenceController — manages SwiftData ModelContainer and ModelContext

AppDIContainer — central dependency injection setup

🌐 API Integration
Remote data source functions:

getAllIngredients()

getAllCategory()

getAllArea()

getBySingleIngredient(_:)

getByCategory(_:)

searchByName(_:)

getRecipeDetail(id:)

getRandomRecipe()

Special endpoints:

Example: list.php?c=list returns categories as strings

Example: filter.php?i=Beef returns recipes filtered by ingredient

💾 Local Caching
String lists (categories, areas) are stored in UserDefaults

Recipes & Ingredients are stored in SwiftData

Repository decides when to use cache vs. remote

Favorites stored as isFavorite in RecipeEntity

updateFavorite(id:isFavorite:)

getAllFavoriteRecipes()

🖥 UI Features
Home Page

Loads in parallel:

Random recipe

Area list

Category list

Recipes by ingredient ("Beef")

Skeleton loader until all data is ready

LoadedHomePageView shows:

Featured dish card

Horizontal beef recipes scroll

Categories & Areas as chips (wrapping layout)

Profile Page

Renders SettingsScreen without account login

Shows storage overview, data tools, about links, and open-source links

Startup cleanup removes legacy fake-login UserDefaults keys from older installs

🧩 Utility & UI Components
RecipeCardSmall / RecipeCardLarge — reusable recipe cards

TagChip — pill-shaped text view

FlowLayout — custom wrapping layout for chips

CategoryChip — square image + text chip

IngredientChip — ingredient name, dose, and image

SkeletonHomePageView — loading placeholder

🧪 Testing & Preview Support
DummyRecipeRepository for SwiftUI previews / UI testing

Mappers & ViewModels designed for unit testing

Previews use .sample static instances for UIRecipeItem

⚙️ Dependency Injection Setup
AppDIContainer:

Holds:

NetworkClient

RecipeRemoteDataSource

RecipeLocalDataSource

RecipeRepository

Factory functions for ViewModels:

makeHomeViewModel()

Injected into SwiftUI views using:

Manual init(viewModel:) DI

Or via @Environment if global access is needed

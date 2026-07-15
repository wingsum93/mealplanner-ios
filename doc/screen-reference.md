# Screen Reference

Quick lookup for SwiftUI screen names and their ViewModels. Use this when you need to find the page type, the backing ViewModel, or where a page appears in the app.

## App Shell

| App area | Screen / container | ViewModel(s) | Where it appears | Notes |
| --- | --- | --- | --- | --- |
| App entry | `RecipeApp` | Creates `FeatureViewModel`, `AuthViewModel`, `DetailViewModel`, `FavouriteViewModel`, `SettingsViewModel` | `Meal Planner/RecipeApp.swift` | App root. Builds DI and injects shared ViewModels into the view tree. |
| Root tabs | `RootTabs` | `FeatureViewModel`, `AuthViewModel`, `SettingsViewModel`, environment `DetailViewModel` | `Features/Home/RootTabs.swift` | Main tab shell: Home, Favourite, Profile. Also owns the detail sheet presentation. |
| Home navigation stack | `RecipeMainPage` | `FeatureViewModel`, environment `DetailViewModel` | `Features/Home/RecipeMainPage.swift` | Home tab container. Routes to area list, category list, search, and random pick. |

## Home Feature

Backed by `FeatureViewModel`.

| User-facing page | SwiftUI screen | ViewModel(s) | Route / trigger | Notes |
| --- | --- | --- | --- | --- |
| Recipes / Home | `HomeScreen` | `FeatureViewModel`, environment `DetailViewModel` | Default page inside `RecipeMainPage` | Shows search entry, featured recipe, areas, categories, and discover/random recipes. |
| Area recipe list | `TitleListScreen` | Data passed from `FeatureViewModel`; detail uses environment `DetailViewModel` through parent callback | `Route.area(String)` from tapping an area chip | Reused list screen. Navigation title is the selected area name. |
| Category recipe list | `TitleListScreen` | Data passed from `FeatureViewModel`; detail uses environment `DetailViewModel` through parent callback | `Route.category(String)` from tapping a category chip | Same screen as area list. Navigation title is the selected category name. |
| Search | `SearchScreen` | Bindings and callbacks from `FeatureViewModel`; detail uses environment `DetailViewModel` through parent callback | `Route.search` from Home search bar | Search UI is in `Features/Home`, while row/empty/skeleton pieces live in `Features/Search`. |
| Random Pick | `RandomPickScreen` | `FeatureViewModel` | `Route.randomPick` from Home Discover section | Loads 10 random recipes and displays them in a swipe card stack. |

## Favourite Feature

Backed by `FavouriteViewModel`.

| User-facing page | SwiftUI screen | ViewModel(s) | Route / trigger | Notes |
| --- | --- | --- | --- | --- |
| Favourite tab | `FavouriteScreen` | Environment `FavouriteViewModel`, environment `DetailViewModel` | Favourite tab in `RootTabs` | Shows saved recipes, area/category filters, empty state, and opens recipe detail on item tap. |

## Profile / Auth Feature

Backed by `AuthViewModel` and `SettingsViewModel`.

| User-facing page | SwiftUI screen | ViewModel(s) | Route / trigger | Notes |
| --- | --- | --- | --- | --- |
| Profile tab | `ProfileScreen` | `AuthViewModel`, `SettingsViewModel` | Profile tab in `RootTabs` | Wrapper that loads auth state and renders `SettingsScreen`. |
| Settings / profile content | `SettingsScreen` | `SettingsViewModel`; login state from `AuthViewModel` via `ProfileScreen` | Rendered by `ProfileScreen` | Shows account actions, data actions, about links, and open-source links. |
| Login bottom sheet | `LoginBottomSheet` | `AuthViewModel` | Not currently wired from `RootTabs` | Login form UI. `RootTabs` has `showLoginDialog`, but no active `.sheet` for this view. |

## Detail Feature

Backed by `DetailViewModel`.

| User-facing page | SwiftUI screen | ViewModel(s) | Route / trigger | Notes |
| --- | --- | --- | --- | --- |
| Recipe detail sheet | `DetailSheetView` | `DetailViewModel` | Presented by `RootTabs` when `detailVM.state.showDetail` is true | Shared sheet used from Home, list/search results, and Favourite. Handles favorite toggle through `DetailViewModel`. |

## Shared / Component Views

These are reusable UI pieces, not standalone pages. They usually do not own a ViewModel.

| Feature area | Component views |
| --- | --- |
| Home | `RecipeHeroCard`, `SkeletonHomePageView`, `WrapHStack` |
| Search | `SearchRecipeRow`, `EmptySearchPlaceholder`, `SkeletonSearchListView` |
| Detail | `TextChip` |
| Core | `SelfEsteem` |
| Core components | `SectionHeader`, `TagChip`, `ErrorView`, `SpiningCatLoadingView`, `WrapLayout`, `SearchField`, `ImageSquareChip`, `EmptyStateView`, `LottieView`, `IngredientChip`, `RecipeCardSmall`, `FlowLayout`, `TagChipsRow`, `RandomPickLoadingView`, `SearchBar`, `CardStackView`, `IconTextRow`, `YoutubeRoundedButton` |

## ViewModel Ownership

| ViewModel | Feature | Main screen users | Created in |
| --- | --- | --- | --- |
| `FeatureViewModel` | Home | `RootTabs`, `RecipeMainPage`, `HomeScreen`, `RandomPickScreen`; feeds `TitleListScreen` and `SearchScreen` by bindings/callbacks | `RecipeApp` |
| `DetailViewModel` | Detail | `RootTabs`, `RecipeMainPage`, `HomeScreen`, `FavouriteScreen`, `DetailSheetView` | `RecipeApp` |
| `FavouriteViewModel` | Favourite | `FavouriteScreen` | `RecipeApp` |
| `AuthViewModel` | Profile/Auth | `RootTabs`, `ProfileScreen`, `LoginBottomSheet` | `RecipeApp` |
| `SettingsViewModel` | Profile/Settings | `RootTabs`, `ProfileScreen`, `SettingsScreen` | `RecipeApp` |

## Route Reference

Routes are defined in `Features/Home/HomeState.swift` and consumed in `RecipeMainPage`.

| Route | Screen | ViewModel state used |
| --- | --- | --- |
| `.area(String)` | `TitleListScreen` | `FeatureState.area` |
| `.category(String)` | `TitleListScreen` | `FeatureState.category` |
| `.search` | `SearchScreen` | `FeatureState.search` |
| `.randomPick` | `RandomPickScreen` | `FeatureState.randomPick` |

## Not Currently In Main App Flow

| Screen | File | Notes |
| --- | --- | --- |
| `ContentView` | `Meal Planner/ContentView.swift` | Template/sample SwiftData view. `RecipeApp` does not use it as the current root. |
| `UnloggedInView` | `Features/login/UnloggedInView.swift` | Login prompt view with preview, but no current references in the active app flow. |
| `LoginBottomSheet` | `Features/login/LoginBottomSheet.swift` | Login sheet UI exists, but no active presentation modifier currently points to it. |

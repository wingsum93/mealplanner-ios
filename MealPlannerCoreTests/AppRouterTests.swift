//
//  AppRouterTests.swift
//  Meal PlannerTests
//
//  Created by Codex on 15/7/2026.
//

import Testing

struct AppRouterTests {

    @MainActor
    @Test func pathCanPushPopAndReplaceRoutes() {
        let router = AppRouter()

        router.push(.search)
        router.push(.area("Canadian"))
        #expect(router.path == [.search, .area("Canadian")])

        router.pop()
        #expect(router.path == [.search])

        router.replacePath([.category("Seafood")])
        #expect(router.path == [.category("Seafood")])

        router.pop()
        router.pop()
        #expect(router.path.isEmpty)
    }

    @MainActor
    @Test func recipeDetailSheetCanBePresentedAndDismissed() {
        let router = AppRouter()
        let item = UIRecipeItem.new(id: "1", name: "One")

        router.presentRecipeDetail(item)
        #expect(router.activeSheet == .recipeDetail(item))

        router.dismissSheet()
        #expect(router.activeSheet == nil)
    }

    @MainActor
    @Test func randomPickFullScreenCoverCanBePresentedAndDismissed() {
        let router = AppRouter()

        router.presentRandomPick()
        #expect(router.activeFullScreenCover == .randomPick)

        router.dismissFullScreenCover()
        #expect(router.activeFullScreenCover == nil)
    }

    @MainActor
    @Test func showIngredientMealsSelectsHomePushesRouteAndDismissesSheet() {
        let router = AppRouter()
        let item = UIRecipeItem.new(id: "1", name: "One")
        router.selectedTab = .favourite
        router.presentRecipeDetail(item)

        router.showIngredientMeals("Beef")

        #expect(router.selectedTab == .home)
        #expect(router.path == [.ingredient("Beef")])
        #expect(router.activeSheet == nil)
    }
}

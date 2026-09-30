//
//  SnapshotTest.swift
//  SnapshotTest
//
//  Generates UI screenshots for the main app screens.
//

import XCTest

final class SnapshotTest: XCTestCase {
    private let defaultTimeout: TimeInterval = 30
    private let renderSettleDelay: TimeInterval = 0.8

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCaptureHomeTab() throws {
        let app = launchInMemoryApp()

        selectTab("Home", in: app)
        XCTAssertTrue(waitForPlanHomeContent(in: app), "Home tab did not finish rendering.")
        capture("01-home", in: app)
    }

    @MainActor
    func testCaptureRecipeTab() throws {
        let app = launchInMemoryApp()

        selectTab("Recipe", in: app)
        waitForRecipeContent(in: app)
        capture("02-recipe", in: app)

        captureSearchScreens(in: app)
        captureAreaList(in: app)
        captureCategoryList(in: app)
        captureIngredientScreens(in: app)
        captureRandomPick(in: app)
        captureDetailSheet(in: app)
    }

    @MainActor
    func testCaptureMyListTab() throws {
        let app = launchInMemoryApp()

        selectTab("My List", in: app)
        captureMyList(in: app)
    }

    @MainActor
    func testCaptureSettingTab() throws {
        let app = launchInMemoryApp()

        selectTab("Setting", in: app)
        captureSetting(in: app)
    }

    private func launchInMemoryApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingInMemoryStore"]
        app.launch()
        return app
    }

    private func captureSearchScreens(in app: XCUIApplication) {
        tap("recipe.searchEntry", in: app)
        XCTAssertTrue(waitFor("search.container", in: app), "Search screen did not open.")
        XCTAssertTrue(
            app.staticTexts["Search for a recipe..."].waitForExistence(timeout: defaultTimeout),
            "Search idle state did not render."
        )
        capture("03-search-idle", in: app)

        let identifiedSearchField = app.textFields["search.field"]
        let placeholderSearchField = app.textFields["Search recipes…"]
        let searchField = identifiedSearchField.waitForExistence(timeout: 5)
            ? identifiedSearchField
            : placeholderSearchField
        XCTAssertTrue(searchField.waitForExistence(timeout: defaultTimeout), "Search field did not appear.")
        searchField.tap()
        searchField.typeText("chicken")
        submitKeyboardSearchIfPresent(in: app)

        waitForSearchResultsState(in: app)
        capture("04-search-results", in: app)
        navigateBack(in: app)
        waitForRecipeContent(in: app)
    }

    private func captureAreaList(in app: XCUIApplication) {
        tap("recipe.areaChip.0", in: app)
        waitForTitleListScreen("Area list", in: app)
        capture("05-area-list", in: app)
        navigateBack(in: app)
        waitForRecipeContent(in: app)
    }

    private func captureCategoryList(in app: XCUIApplication) {
        tap("recipe.categoryChip.0", in: app)
        waitForTitleListScreen("Category list", in: app)
        capture("06-category-list", in: app)
        navigateBack(in: app)
        waitForRecipeContent(in: app)
    }

    private func captureIngredientScreens(in app: XCUIApplication) {
        selectTab("Recipe", in: app)
        waitForRecipeContent(in: app)

        tapIngredientsSeeAll(in: app)
        if waitFor("ingredientList.screen", in: app, timeout: 8) {
            _ = waitForAny(["ingredientList.card.0", "ingredientList.grid"], in: app, timeout: 12)
            capture("07-ingredient-list", in: app)

            if element("ingredientList.card.0", in: app).exists {
                tap("ingredientList.card.0", in: app)
                waitForTitleListScreen("Ingredient meals list", in: app)
                capture("08-ingredient-meals", in: app)
                navigateBack(in: app)
                navigateBack(in: app)
            } else {
                navigateBack(in: app)
                waitForRecipeContent(in: app)
                captureIngredientMealsFromHomeStrip(in: app)
            }
        } else {
            XCTAssertTrue(
                waitFor("recipe.ingredientsScroll", in: app, timeout: 1),
                "Ingredient list did not open and home ingredient strip was not visible."
            )
            capture("07-ingredient-list", in: app)
            captureIngredientMealsFromHomeStrip(in: app)
        }

        waitForRecipeContent(in: app)
    }

    private func captureRandomPick(in app: XCUIApplication) {
        tap("recipe.randomPickCard", in: app)
        XCTAssertTrue(
            app.navigationBars.staticTexts["Random Pick"].waitForExistence(timeout: defaultTimeout),
            "Random Pick screen did not open."
        )
        _ = waitForAny(
            ["randomPick.topCard", "randomPick.content", "randomPick.empty", "randomPick.error"],
            in: app,
            timeout: 12
        )
        capture("09-random-pick", in: app)

        let closeButton = app.buttons["Close"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: defaultTimeout), "Random Pick close button did not appear.")
        closeButton.tap()
        waitForRecipeContent(in: app)
    }

    private func captureMyList(in app: XCUIApplication) {
        captureMyListSegment("Favourite", named: "11-my-list-favourite", in: app)
        captureMyListSegment("Mastered", named: "12-my-list-mastered", in: app)
        captureMyListSegment("Recently Viewed", named: "13-my-list-recently-viewed", in: app)
    }

    private func captureMyListSegment(_ label: String, named snapshotName: String, in app: XCUIApplication) {
        let segment = myListSegment(label, in: app)
        XCTAssertTrue(segment.waitForExistence(timeout: defaultTimeout), "\(label) My List segment did not appear.")
        segment.tap()
        XCTAssertTrue(waitForMyListContent(in: app), "\(label) My List segment did not finish rendering.")
        capture(snapshotName, in: app)
    }

    private func captureSetting(in app: XCUIApplication) {
        XCTAssertTrue(waitFor("settings.screen", in: app), "Setting screen did not render.")
        capture("14-setting", in: app)
    }

    private func captureDetailSheet(in app: XCUIApplication) {
        selectTab("Recipe", in: app)

        waitForRecipeContent(in: app)
        tap("recipe.featuredRecipeButton", in: app)
        XCTAssertTrue(waitFor("detail.sheet", in: app), "Detail sheet did not render.")
        capture("10-detail-sheet", in: app)

        let ingredientsTab = app.buttons["Ingredients"]
        XCTAssertTrue(ingredientsTab.waitForExistence(timeout: defaultTimeout), "Ingredients tab did not appear.")
        ingredientsTab.tap()
        tap("detail.ingredientChip.0", in: app)
        waitForTitleListScreen("Ingredient meals list from detail", in: app)
    }

    private func waitForPlanHomeContent(in app: XCUIApplication) -> Bool {
        waitForAny(["planHome.empty", "planHome.newPlanButton", "planHome.error"], in: app)
    }

    private func waitForRecipeContent(in app: XCUIApplication) {
        XCTAssertTrue(waitFor("recipe.featuredRecipe", in: app), "Recipe featured recipe did not load.")
        XCTAssertTrue(waitFor("recipe.randomPickCard", in: app), "Recipe content did not finish loading.")
    }

    private func waitForMyListContent(in app: XCUIApplication) -> Bool {
        waitForAny(["myList.empty", "myList.list", "myList.error"], in: app)
    }

    private func tapIngredientsSeeAll(in app: XCUIApplication) {
        let seeAllButton = app.buttons["See all ingredients"]
        if waitAndReveal(seeAllButton, in: app, maxSwipes: 2) {
            seeAllButton.tap()
            return
        }

        tap("recipe.ingredientsSeeAll", in: app)
    }

    private func captureIngredientMealsFromHomeStrip(in app: XCUIApplication) {
        tap("recipe.ingredientChip.0", in: app)
        waitForTitleListScreen("Ingredient meals list", in: app)
        capture("08-ingredient-meals", in: app)
        navigateBack(in: app)
    }

    private func waitForSearchResultsState(in app: XCUIApplication) {
        _ = waitForAny(["search.resultRow.0", "search.results", "search.empty", "search.error"], in: app, timeout: 20)
        XCTAssertTrue(
            waitForAny(["search.resultRow.0", "search.results", "search.empty", "search.error", "search.loading"], in: app, timeout: 1),
            "Search screen did not render a results, empty, error, or loading state."
        )
    }

    private func waitForTitleListScreen(_ description: String, in app: XCUIApplication) {
        XCTAssertTrue(waitFor("titleList.screen", in: app), "\(description) screen did not open.")
        _ = waitForAny(["titleList.recipeCard.0", "titleList.grid"], in: app, timeout: 12)
    }

    private func myListSegment(_ label: String, in app: XCUIApplication) -> XCUIElement {
        let identifiedSegment = app.segmentedControls["myList.segment"].buttons[label]
        if identifiedSegment.waitForExistence(timeout: 3) {
            return identifiedSegment
        }
        return app.buttons[label]
    }

    private func selectTab(_ label: String, in app: XCUIApplication) {
        let tab = app.tabBars.buttons[label]
        XCTAssertTrue(tab.waitForExistence(timeout: defaultTimeout), "\(label) tab did not appear.")
        tab.tap()
    }

    private func tap(
        _ identifier: String,
        in app: XCUIApplication,
        horizontalContainerIdentifier: String? = nil,
        maxSwipes: Int = 8
    ) {
        let target = element(identifier, in: app)
        XCTAssertTrue(
            waitAndReveal(target, in: app, maxSwipes: maxSwipes, horizontalContainerIdentifier: horizontalContainerIdentifier),
            "\(identifier) was not found in a visible frame."
        )
        target.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }

    private func capture(_ name: String, in app: XCUIApplication) {
        Thread.sleep(forTimeInterval: renderSettleDelay)
        SnapshotScreenshotWriter.write(app.screenshot(), named: name)
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func waitFor(_ identifier: String, in app: XCUIApplication, timeout: TimeInterval? = nil) -> Bool {
        element(identifier, in: app).waitForExistence(timeout: timeout ?? defaultTimeout)
    }

    private func waitForAny(
        _ identifiers: [String],
        in app: XCUIApplication,
        timeout: TimeInterval? = nil
    ) -> Bool {
        let deadline = Date().addingTimeInterval(timeout ?? defaultTimeout)
        repeat {
            if identifiers.contains(where: { element($0, in: app).exists }) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.25))
        } while Date() < deadline
        return false
    }

    private func waitAndReveal(
        _ element: XCUIElement,
        in app: XCUIApplication,
        maxSwipes: Int = 8,
        horizontalContainerIdentifier: String? = nil
    ) -> Bool {
        if element.waitForExistence(timeout: 3), isVisible(element, in: app) {
            return true
        }

        if let horizontalContainerIdentifier {
            let container = self.element(horizontalContainerIdentifier, in: app)
            guard container.waitForExistence(timeout: defaultTimeout) else {
                return false
            }

            revealVertically(container, in: app, maxSwipes: maxSwipes)

            if element.waitForExistence(timeout: 1), isVisible(element, in: app) {
                return true
            }

            for _ in 0..<maxSwipes {
                container.swipeLeft()
                RunLoop.current.run(until: Date().addingTimeInterval(0.2))
                if element.exists, isVisible(element, in: app) {
                    return true
                }
            }

            return false
        }

        for _ in 0..<maxSwipes {
            app.swipeUp()
            if element.waitForExistence(timeout: 1), isVisible(element, in: app) {
                return true
            }
        }

        for _ in 0..<maxSwipes {
            app.swipeDown()
            if element.waitForExistence(timeout: 1), isVisible(element, in: app) {
                return true
            }
        }

        return element.waitForExistence(timeout: 1) && isVisible(element, in: app)
    }

    private func revealVertically(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int) {
        if isVisible(element, in: app) {
            return
        }

        for _ in 0..<maxSwipes {
            app.swipeUp()
            if isVisible(element, in: app) {
                return
            }
        }

        for _ in 0..<maxSwipes {
            app.swipeDown()
            if isVisible(element, in: app) {
                return
            }
        }
    }

    private func isVisible(_ element: XCUIElement, in app: XCUIApplication) -> Bool {
        guard element.exists else { return false }
        let frame = element.frame
        return !frame.isEmpty && app.frame.intersects(frame)
    }

    private func navigateBack(in app: XCUIApplication) {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: defaultTimeout), "Navigation back button did not appear.")
        backButton.tap()
    }

    private func submitKeyboardSearchIfPresent(in app: XCUIApplication) {
        let searchButton = app.keyboards.buttons["Search"]
        if searchButton.waitForExistence(timeout: 2) {
            searchButton.tap()
        }
    }
}

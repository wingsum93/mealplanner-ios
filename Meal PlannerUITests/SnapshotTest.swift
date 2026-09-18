//
//  SnapshotTest.swift
//  Meal PlannerUITests
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
    func testCaptureMainScreens() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingInMemoryStore"]
        app.launch()

        waitForHomeContent(in: app)
        capture("01-home", in: app)

        captureSearchScreens(in: app)
        captureAreaList(in: app)
        captureCategoryList(in: app)
        captureIngredientScreens(in: app)
        captureRandomPick(in: app)
        captureFavourites(in: app)
        captureProfile(in: app)
        captureDetailSheet(in: app)
    }

    private func captureSearchScreens(in app: XCUIApplication) {
        tap("home.searchEntry", in: app)
        XCTAssertTrue(waitFor("search.container", in: app), "Search screen did not open.")
        XCTAssertTrue(
            app.staticTexts["Search for a recipe..."].waitForExistence(timeout: defaultTimeout),
            "Search idle state did not render."
        )
        capture("02-search-idle", in: app)

        let identifiedSearchField = app.textFields["search.field"]
        let placeholderSearchField = app.textFields["Search recipes…"]
        let searchField = identifiedSearchField.waitForExistence(timeout: 5)
            ? identifiedSearchField
            : placeholderSearchField
        XCTAssertTrue(searchField.waitForExistence(timeout: defaultTimeout), "Search field did not appear.")
        searchField.tap()
        searchField.typeText("chicken")
        submitKeyboardSearchIfPresent(in: app)

        XCTAssertTrue(waitFor("search.resultRow.0", in: app), "Search results did not load for query 'chicken'.")
        capture("03-search-results", in: app)
        navigateBack(in: app)
        waitForHomeContent(in: app)
    }

    private func captureAreaList(in app: XCUIApplication) {
        tap("home.areaChip.0", in: app)
        XCTAssertTrue(waitFor("titleList.recipeCard.0", in: app), "Area list did not load recipe cards.")
        capture("04-area-list", in: app)
        navigateBack(in: app)
        waitForHomeContent(in: app)
    }

    private func captureCategoryList(in app: XCUIApplication) {
        tap("home.categoryChip.0", in: app)
        XCTAssertTrue(waitFor("titleList.recipeCard.0", in: app), "Category list did not load recipe cards.")
        capture("05-category-list", in: app)
        navigateBack(in: app)
        waitForHomeContent(in: app)
    }

    private func captureIngredientScreens(in app: XCUIApplication) {
        tap("home.ingredientsSeeAll", in: app)
        XCTAssertTrue(waitFor("ingredientList.card.0", in: app), "Ingredient list did not load cards.")
        capture("06-ingredient-list", in: app)

        tap("ingredientList.card.0", in: app)
        XCTAssertTrue(waitFor("titleList.recipeCard.0", in: app), "Ingredient meals list did not load recipe cards.")
        capture("07-ingredient-meals", in: app)
        navigateBack(in: app)
        navigateBack(in: app)
        waitForHomeContent(in: app)
    }

    private func captureRandomPick(in app: XCUIApplication) {
        tap("home.randomPickCard", in: app)
        XCTAssertTrue(
            app.navigationBars.staticTexts["Random Pick"].waitForExistence(timeout: defaultTimeout),
            "Random Pick screen did not open."
        )
        _ = waitForAny(
            ["randomPick.topCard", "randomPick.content", "randomPick.empty", "randomPick.error"],
            in: app,
            timeout: 12
        )
        capture("08-random-pick", in: app)

        let closeButton = app.buttons["Close"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: defaultTimeout), "Random Pick close button did not appear.")
        closeButton.tap()
        waitForHomeContent(in: app)
    }

    private func captureFavourites(in app: XCUIApplication) {
        let favouriteTab = app.tabBars.buttons["Favourite"]
        XCTAssertTrue(favouriteTab.waitForExistence(timeout: defaultTimeout), "Favourite tab did not appear.")
        favouriteTab.tap()

        XCTAssertTrue(
            waitForAny(["favourite.empty", "favourite.list", "favourite.error"], in: app),
            "Favourite screen did not finish rendering."
        )
        capture("09-favourites", in: app)
    }

    private func captureProfile(in app: XCUIApplication) {
        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: defaultTimeout), "Profile tab did not appear.")
        profileTab.tap()

        XCTAssertTrue(waitFor("settings.screen", in: app), "Profile/settings screen did not render.")
        capture("10-profile", in: app)
    }

    private func captureDetailSheet(in app: XCUIApplication) {
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: defaultTimeout), "Home tab did not appear.")
        homeTab.tap()

        waitForHomeContent(in: app)
        tap("home.featuredRecipeButton", in: app)
        XCTAssertTrue(waitFor("detail.sheet", in: app), "Detail sheet did not render.")
        capture("11-detail-sheet", in: app)

        let ingredientsTab = app.buttons["Ingredients"]
        XCTAssertTrue(ingredientsTab.waitForExistence(timeout: defaultTimeout), "Ingredients tab did not appear.")
        ingredientsTab.tap()
        tap("detail.ingredientChip.0", in: app)
        XCTAssertTrue(waitFor("titleList.recipeCard.0", in: app), "Ingredient meals list did not load from detail.")
        capture("12-detail-ingredient-meals", in: app)
    }

    private func waitForHomeContent(in app: XCUIApplication) {
        XCTAssertTrue(waitFor("home.featuredRecipe", in: app), "Home featured recipe did not load.")
        XCTAssertTrue(waitFor("home.randomPickCard", in: app), "Home content did not finish loading.")
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
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func waitFor(_ identifier: String, in app: XCUIApplication) -> Bool {
        element(identifier, in: app).waitForExistence(timeout: defaultTimeout)
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

//
//  Meal_PlannerUITests.swift
//  Meal PlannerUITests
//
//  Created by eric ho on 3/8/2025.
//

import XCTest

final class Meal_PlannerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testMyListTabFirstVisitShowsEmptyStateAfterLoading() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingInMemoryStore"]
        app.launch()

        let myListTab = app.tabBars.buttons["My List"]
        XCTAssertTrue(myListTab.waitForExistence(timeout: 5), "My List tab was not found.")
        myListTab.tap()

        let myListTitle = app.navigationBars.staticTexts["My List"]
        XCTAssertTrue(myListTitle.waitForExistence(timeout: 5), "My List navigation title did not appear.")

        let emptyState = app.otherElements["myList.empty"]
        XCTAssertTrue(emptyState.waitForExistence(timeout: 5), "My List empty state did not appear after loading.")
    }

    @MainActor
    func testNavigateToSearchFromHomeSearchEntry() throws {
        let app = XCUIApplication()
        app.launch()

        selectRecipeTab(in: app)

        let searchEntry = app.buttons["recipe.searchEntry"]
        XCTAssertTrue(waitAndReveal(element: searchEntry, in: app), "Home search entry was not found.")
        searchEntry.tap()

        let searchTitle = app.navigationBars.staticTexts["Search"]
        XCTAssertTrue(searchTitle.waitForExistence(timeout: 5), "Failed to open Search screen.")

        let identifiedSearchField = app.textFields["search.field"]
        let placeholderSearchField = app.textFields["Search recipes…"]
        let didFindSearchField = identifiedSearchField.waitForExistence(timeout: 3) || placeholderSearchField.waitForExistence(timeout: 3)
        XCTAssertTrue(didFindSearchField, "Search field did not appear.")
    }

    @MainActor
    func testNavigateToRandomPickAndCapture() throws {
        let app = XCUIApplication()
        app.launch()

        selectRecipeTab(in: app)

        let randomPickButton = app.buttons["Random Pick"]
        XCTAssertTrue(waitAndReveal(element: randomPickButton, in: app), "Random Pick button was not found on Home screen.")
        randomPickButton.tap()

        let randomPickTitle = app.navigationBars.staticTexts["Random Pick"]
        XCTAssertTrue(randomPickTitle.waitForExistence(timeout: 10), "Failed to open Random Pick screen.")

        let topCard = app.otherElements["randomPick.topCard"].firstMatch
        XCTAssertTrue(topCard.waitForExistence(timeout: 15), "Top random pick card was not found.")
        XCTAssertTrue(topCard.isHittable, "Top random pick card should be hittable.")

        let appFrame = app.frame
        XCTAssertGreaterThan(topCard.frame.width, 0, "Top random pick card width should be non-zero.")
        XCTAssertGreaterThan(topCard.frame.height, 0, "Top random pick card height should be non-zero.")
        XCTAssertLessThan(topCard.frame.width, appFrame.width * 0.95, "Top random pick card should not stretch to full screen width.")
        XCTAssertEqual(
            topCard.frame.width / topCard.frame.height,
            9.0 / 16.0,
            accuracy: 0.02,
            "Top random pick card should keep the portrait 9:16 aspect ratio."
        )

        let minimumHorizontalInset: CGFloat = 20
        let leftInset = topCard.frame.minX - appFrame.minX
        let rightInset = appFrame.maxX - topCard.frame.maxX
        XCTAssertGreaterThanOrEqual(leftInset, minimumHorizontalInset - 1, "Top random pick card should keep left screen padding.")
        XCTAssertGreaterThanOrEqual(rightInset, minimumHorizontalInset - 1, "Top random pick card should keep right screen padding.")
        XCTAssertEqual(leftInset, rightInset, accuracy: 2, "Top random pick card should stay horizontally centered.")

        let topCardImage = app.otherElements["randomPick.topCard.image"].firstMatch
        XCTAssertTrue(topCardImage.exists, "Top random pick image layer was not found.")

        // Give async image loading a short window before capture.
        sleep(2)
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "random-pick-screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testMealPlanWizardOpensFromHomeAndAdvancesToMealPicker() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingInMemoryStore"]
        app.launch()

        let homeTitle = app.navigationBars.staticTexts["Meal Plans"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 5), "Meal Plans home did not appear.")

        let newPlan = app.buttons["planHome.newPlan"]
        XCTAssertTrue(newPlan.waitForExistence(timeout: 5), "New Plan button was not found.")
        newPlan.tap()

        let wizardTitle = app.navigationBars.staticTexts["Plan Period"]
        XCTAssertTrue(wizardTitle.waitForExistence(timeout: 5), "Meal plan wizard did not open.")

        let caption = app.staticTexts["planWizard.slotCaption"]
        XCTAssertTrue(caption.waitForExistence(timeout: 5), "Slot caption was not shown on step 1.")

        let next = app.buttons["planWizard.next"]
        XCTAssertTrue(next.waitForExistence(timeout: 5), "Next button was not found.")
        next.tap()

        let sourceTab = app.segmentedControls["planWizard.sourceTab"]
        XCTAssertTrue(sourceTab.waitForExistence(timeout: 5), "Meal picker step did not appear.")
    }

    @MainActor
    func testSavedPlanCalendarMoveAndUndo() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingInMemoryStore", "-uiTestingFX002Fixture"]
        app.launch()

        let card = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "planHome.card.")).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        card.tap()
        XCTAssertTrue(app.buttons["planCalendar.next"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["planCalendar.next"].isEnabled)
        app.buttons["planCalendar.next"].tap()
        XCTAssertFalse(app.buttons["planCalendar.next"].isEnabled)
        app.buttons["planCalendar.previous"].tap()
        let today = Calendar.current.component(.day, from: Date())
        app.buttons["planCalendar.day.\(today)"].tap()
        XCTAssertTrue(app.navigationBars["Day Meals"].waitForExistence(timeout: 5))

        let move = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "planDay.move.")).firstMatch
        XCTAssertTrue(move.waitForExistence(timeout: 5), app.debugDescription)
        move.tap()
        let sameDay = app.buttons["planMove.destination.0"]
        XCTAssertTrue(sameDay.waitForExistence(timeout: 5))
        sameDay.tap()
        XCTAssertTrue(app.buttons["planDay.undo"].waitForExistence(timeout: 5))
        app.buttons["planDay.undo"].tap()
        XCTAssertTrue(app.staticTexts["Beef Bowl"].exists)

        move.tap()
        let crossDay = app.buttons["planMove.destination.2"]
        XCTAssertTrue(crossDay.waitForExistence(timeout: 5))
        crossDay.tap()
        XCTAssertTrue(app.buttons["planDay.undo"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSavedPlanIngredientTabsAndCheckState() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingInMemoryStore", "-uiTestingFX002Fixture"]
        app.launch()
        let card = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "planHome.card.")).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        card.tap()
        XCTAssertTrue(app.buttons["planDetail.ingredients"].label.contains("2 items"), app.debugDescription)
        app.buttons["planDetail.ingredients"].tap()
        XCTAssertTrue(app.staticTexts["Beef"].waitForExistence(timeout: 5), app.debugDescription)
        let beef = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "planIngredients.item.")).firstMatch
        beef.tap()
        let checked = NSPredicate(format: "value == %@", "Checked")
        expectation(for: checked, evaluatedWith: beef)
        waitForExpectations(timeout: 5)
        app.buttons["planIngredients.tab.Seafood"].tap()
        XCTAssertTrue(app.staticTexts["No seafood ingredients"].waitForExistence(timeout: 5))
        app.buttons["planIngredients.tab.Vegetable"].tap()
        XCTAssertTrue(app.staticTexts["Carrot"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSavedPlanDragTargets() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingInMemoryStore", "-uiTestingFX002Fixture"]
        app.launch()
        let card = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "planHome.card.")).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        card.tap()
        let today = Calendar.current.component(.day, from: Date())
        app.buttons["planCalendar.day.\(today)"].tap()
        let meal = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "planDay.meal.")).firstMatch
        let emptyDinner = app.descendants(matching: .any)["planDay.empty.dinner"]
        XCTAssertTrue(meal.waitForExistence(timeout: 5))
        XCTAssertTrue(emptyDinner.waitForExistence(timeout: 5))
        meal.press(forDuration: 1, thenDragTo: emptyDinner)
        XCTAssertTrue(app.buttons["planDay.undo"].waitForExistence(timeout: 5))
        app.buttons["planDay.undo"].tap()

        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        if !Calendar.current.isDate(tomorrow, equalTo: Date(), toGranularity: .month) {
            app.buttons["planCalendar.next"].tap()
        }
        let tomorrowDay = Calendar.current.component(.day, from: tomorrow)
        meal.press(forDuration: 1, thenDragTo: app.buttons["planCalendar.day.\(tomorrowDay)"])
        XCTAssertTrue(app.buttons["Lunch"].waitForExistence(timeout: 5))
        app.buttons["Lunch"].tap()
        XCTAssertTrue(app.buttons["planDay.undo"].waitForExistence(timeout: 5))
    }

    private func selectRecipeTab(in app: XCUIApplication) {
        let recipeTab = app.tabBars.buttons["Recipe"]
        XCTAssertTrue(recipeTab.waitForExistence(timeout: 5), "Recipe tab was not found.")
        recipeTab.tap()
    }

    private func waitAndReveal(element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 6) -> Bool {
        if element.waitForExistence(timeout: 3) && element.isHittable {
            return true
        }

        for _ in 0..<maxSwipes {
            app.swipeUp()
            if element.waitForExistence(timeout: 1.5) && element.isHittable {
                return true
            }
        }

        for _ in 0..<maxSwipes {
            app.swipeDown()
            if element.waitForExistence(timeout: 1.5) && element.isHittable {
                return true
            }
        }

        return element.waitForExistence(timeout: 1)
    }
}

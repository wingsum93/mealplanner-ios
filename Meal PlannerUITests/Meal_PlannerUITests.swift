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
    func testNavigateToSearchFromHomeSearchEntry() throws {
        let app = XCUIApplication()
        app.launch()

        let searchEntry = app.buttons["home.searchEntry"]
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
        XCTAssertLessThan(topCard.frame.width, appFrame.width * 0.95, "Top random pick card should not stretch to full screen width.")

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

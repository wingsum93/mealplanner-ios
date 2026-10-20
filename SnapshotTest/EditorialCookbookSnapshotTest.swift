import XCTest

/// Captures the redesigned surfaces without changing persistent user data.
final class EditorialCookbookSnapshotTest: XCTestCase {
    @MainActor
    func testEditorialScreens() {
        continueAfterFailure = false
        for (name, textSize) in [
            ("standard", "UICTContentSizeCategoryL"),
            ("accessible", "UICTContentSizeCategoryAccessibilityXXXL")
        ] {
            let app = XCUIApplication()
            app.launchArguments = [
                "-uiTestingInMemoryStore",
                "-UIPreferredContentSizeCategoryName", textSize
            ]
            app.launch()
            let recipes = app.tabBars.buttons["Recipe"]
            XCTAssertTrue(recipes.waitForExistence(timeout: 10))
            recipes.tap()
            XCTAssertTrue(app.buttons["recipe.searchEntry"].waitForExistence(timeout: 10))
            _ = app.buttons["recipe.featuredRecipeButton"].waitForExistence(timeout: 20)
            capture("recipes-\(name)", app: app)

            app.tabBars.buttons["My List"].tap()
            XCTAssertTrue(app.descendants(matching: .any)["myList.empty"].firstMatch.waitForExistence(timeout: 10))
            capture("my-list-\(name)", app: app)

            app.tabBars.buttons["Setting"].tap()
            XCTAssertTrue(app.staticTexts["Your personal cookbook"].waitForExistence(timeout: 10))
            capture("settings-\(name)", app: app)
            app.terminate()
        }
    }

    @MainActor
    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

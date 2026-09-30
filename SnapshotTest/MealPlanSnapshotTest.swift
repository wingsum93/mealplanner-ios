//
//  MealPlanSnapshotTest.swift
//  SnapshotTest
//
//  Captures UI screenshots for the meal-planning workflows:
//   - Case 1: add a new meal plan (wizard steps 1–5).
//   - Case 2: edit a saved meal plan (detail, day, move, ingredients).
//

import XCTest

final class MealPlanSnapshotTest: XCTestCase {
    private let defaultTimeout: TimeInterval = 30
    private let renderSettleDelay: TimeInterval = 0.8

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Case 1 — Add new meal plan

    @MainActor
    func testAddMealPlanWorkflow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingInMemoryStore"]
        app.launch()

        openNewPlanWizard(in: app)

        // Step 1 — select days (period & timeboxes).
        XCTAssertTrue(waitFor("planWizard.slotCaption", in: app), "Plan period step did not render.")
        capture("12-plan-select-days", in: app)
        tapWizardNext(in: app)

        // Step 2 — select meal. A fresh in-memory store has no saved lists, so use the
        // network-backed "Random (10)" tab to populate the picker.
        XCTAssertTrue(waitFor("planWizard.sourceTab", in: app), "Meal picker step did not appear.")
        selectSourceTab("Random (10)", in: app)
        XCTAssertTrue(
            waitForAnyPrefix(["planWizard.mealRow.", "planWizard.emptyTab"], in: app, timeout: 20),
            "Meal picker did not finish loading."
        )

        let firstMeal = firstElement(prefix: "planWizard.mealRow.", in: app)
        if firstMeal.waitForExistence(timeout: 5) {
            revealAndTap(firstMeal, in: app)
        }
        capture("13-plan-select-meals", in: app)
        tapWizardNext(in: app)

        // Step 3 — schedule review.
        XCTAssertTrue(
            waitForAnyPrefix(["planWizard.slot.", "No schedule yet"], in: app, timeout: defaultTimeout),
            "Schedule step did not render."
        )
        capture("14-plan-schedule", in: app)
        tapWizardNext(in: app)

        // Step 4 — aggregated ingredients.
        XCTAssertTrue(waitFor("planWizard.ingredientCount", in: app), "Ingredients step did not render.")
        capture("15-plan-ingredients", in: app)
        tapWizardNext(in: app)

        // Step 5 — name & preview before saving.
        XCTAssertTrue(waitFor("planWizard.planName", in: app), "Save/preview step did not render.")
        capture("16-plan-preview", in: app)
    }

    // MARK: - Case 2 — Edit a saved meal plan

    @MainActor
    func testEditMealPlanWorkflow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingInMemoryStore", "-uiTestingFX002Fixture"]
        app.launch()

        // View plan page.
        let card = firstElement(prefix: "planHome.card.", in: app)
        XCTAssertTrue(card.waitForExistence(timeout: defaultTimeout), "Saved plan card did not appear.")
        revealAndTap(card, in: app)

        XCTAssertTrue(waitFor("planCalendar.next", in: app), "Plan detail (view plan) did not render.")
        capture("17-plan-view", in: app)

        // Day detail page.
        let today = Calendar.current.component(.day, from: Date())
        tap("planCalendar.day.\(today)", in: app)
        XCTAssertTrue(
            app.navigationBars["Day Meals"].waitForExistence(timeout: defaultTimeout),
            "Day detail screen did not open."
        )
        capture("18-plan-day", in: app)

        // Move destination sheet.
        let move = firstElement(prefix: "planDay.move.", in: app)
        XCTAssertTrue(move.waitForExistence(timeout: defaultTimeout), "No movable meal was found for today.")
        revealAndTap(move, in: app)

        let destination = element("planMove.destination.0", in: app)
        XCTAssertTrue(destination.waitForExistence(timeout: defaultTimeout), "Move destination sheet did not render.")
        capture("19-plan-move", in: app)

        destination.tap()
        XCTAssertTrue(waitFor("planDay.undo", in: app), "Move did not offer an undo action.")
        tap("planDay.undo", in: app)
        navigateBack(in: app)

        // Ingredients page.
        tap("planDetail.ingredients", in: app)
        XCTAssertTrue(
            waitForAnyPrefix(["planIngredients.tab.", "Plan unavailable"], in: app, timeout: defaultTimeout),
            "Ingredients page did not render."
        )
        let firstIngredient = firstElement(prefix: "planIngredients.item.", in: app)
        if firstIngredient.waitForExistence(timeout: 5) {
            revealAndTap(firstIngredient, in: app)
        }
        capture("20-plan-saved-ingredients", in: app)
    }

    // MARK: - Workflow helpers

    private func openNewPlanWizard(in app: XCUIApplication) {
        let newPlan = element("planHome.newPlan", in: app)
        XCTAssertTrue(newPlan.waitForExistence(timeout: defaultTimeout), "New Plan button was not found.")
        revealAndTap(newPlan, in: app)
        XCTAssertTrue(waitFor("planWizard.screen", in: app), "Meal plan wizard did not open.")
    }

    private func tapWizardNext(in app: XCUIApplication) {
        let next = element("planWizard.next", in: app)
        XCTAssertTrue(next.waitForExistence(timeout: defaultTimeout), "Next button was not found.")
        XCTAssertTrue(waitUntilEnabled(next, timeout: defaultTimeout), "Next button stayed disabled.")
        revealAndTap(next, in: app)
    }

    private func selectSourceTab(_ title: String, in app: XCUIApplication) {
        let segmented = app.segmentedControls["planWizard.sourceTab"]
        if segmented.waitForExistence(timeout: 5) {
            let button = segmented.buttons[title]
            XCTAssertTrue(button.waitForExistence(timeout: defaultTimeout), "\(title) tab was not found.")
            button.tap()
            return
        }
        let fallback = app.buttons[title]
        XCTAssertTrue(fallback.waitForExistence(timeout: defaultTimeout), "\(title) tab was not found.")
        fallback.tap()
    }

    // MARK: - Element helpers

    private func capture(_ name: String, in app: XCUIApplication) {
        Thread.sleep(forTimeInterval: renderSettleDelay)
        SnapshotScreenshotWriter.write(app.screenshot(), named: name)
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func firstElement(prefix: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
            .firstMatch
    }

    private func tap(_ identifier: String, in app: XCUIApplication) {
        let target = element(identifier, in: app)
        XCTAssertTrue(reveal(target, in: app), "\(identifier) was not found in a visible frame.")
        target.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }

    private func revealAndTap(_ target: XCUIElement, in app: XCUIApplication) {
        XCTAssertTrue(reveal(target, in: app), "Element was not found in a visible frame.")
        target.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }

    private func waitFor(_ identifier: String, in app: XCUIApplication) -> Bool {
        element(identifier, in: app).waitForExistence(timeout: defaultTimeout)
    }

    private func waitForAnyPrefix(
        _ prefixes: [String],
        in app: XCUIApplication,
        timeout: TimeInterval? = nil
    ) -> Bool {
        let deadline = Date().addingTimeInterval(timeout ?? defaultTimeout)
        repeat {
            if prefixes.contains(where: { firstElement(prefix: $0, in: app).exists }) {
                return true
            }
            if prefixes.contains(where: { element($0, in: app).exists }) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.25))
        } while Date() < deadline
        return false
    }

    private func waitUntilEnabled(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "isEnabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    private func reveal(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 6) -> Bool {
        if element.waitForExistence(timeout: 3), isVisible(element, in: app) {
            return true
        }
        for _ in 0..<maxSwipes {
            app.swipeUp()
            if element.exists, isVisible(element, in: app) {
                return true
            }
        }
        for _ in 0..<maxSwipes {
            app.swipeDown()
            if element.exists, isVisible(element, in: app) {
                return true
            }
        }
        return element.waitForExistence(timeout: 1) && isVisible(element, in: app)
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
}

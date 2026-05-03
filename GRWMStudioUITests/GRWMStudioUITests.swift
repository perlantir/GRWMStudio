import XCTest

final class GRWMStudioUITests: XCTestCase {
    @MainActor
    func testLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertEqual(app.state, .runningForeground)
    }

    @MainActor
    func testFilterRailAccessibilityLabelsAndSelection() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell"]
        app.launch()

        let skin = app.buttons["Skin filter category"]
        XCTAssertTrue(skin.waitForExistence(timeout: 5))
        skin.tap()
        XCTAssertTrue(skin.isSelected)

        let eyes = app.buttons["Eyes filter category"]
        XCTAssertTrue(eyes.exists)
        eyes.tap()
        XCTAssertTrue(eyes.isSelected)
    }

    @MainActor
    func testCountdownCancelStopsBeforeCompletion() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugCountdownOverlay", "-GRWMDebugCountdownSlow"]
        app.launch()

        let cancelButton = app.buttons["countdown-cancel-button"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5))
        cancelButton.tap()

        let status = app.staticTexts["countdown-debug-status"]
        XCTAssertTrue(status.waitForExistence(timeout: 2))
        XCTAssertEqual(status.label, "Canceled")
    }

    @MainActor
    func testShadeSelectionDismissesTray() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell"]
        app.launch()

        let skin = app.buttons["Skin filter category"]
        XCTAssertTrue(skin.waitForExistence(timeout: 8))
        skin.tap()

        let tray = app.scrollViews["shade-tray-skin"]
        XCTAssertTrue(tray.waitForExistence(timeout: 3))

        let fair = app.buttons["Fair Skin shade"]
        XCTAssertTrue(fair.waitForExistence(timeout: 3))
        fair.tap()

        let trayDismissed = NSPredicate(format: "exists == false")
        expectation(for: trayDismissed, evaluatedWith: tray)
        waitForExpectations(timeout: 3)
    }

    @MainActor
    func testVideoModeTapStartsAndStopsRecording() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell"]
        app.launch()

        let videoMode = app.buttons["Video capture mode"]
        XCTAssertTrue(videoMode.waitForExistence(timeout: 8))
        videoMode.tap()

        let capture = app.buttons["capture-fab"]
        XCTAssertTrue(capture.waitForExistence(timeout: 3))
        capture.tap()

        let stopRecording = app.buttons["Stop video recording"]
        XCTAssertTrue(stopRecording.waitForExistence(timeout: 3))
        stopRecording.tap()

        XCTAssertTrue(app.staticTexts["Video Preview"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Back to mirror"].exists)
        XCTAssertTrue(app.buttons["Save"].exists)

        app.buttons["Back to mirror"].tap()

        XCTAssertFalse(app.staticTexts["Video Preview"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["Skin filter category"].exists)
    }

    @MainActor
    func testLooksSelectionDismissesTray() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell"]
        app.launch()

        let rail = app.scrollViews["filter-rail"]
        XCTAssertTrue(rail.waitForExistence(timeout: 8))

        for _ in 0..<5 {
            rail.swipeLeft()
        }

        let looks = app.buttons["Looks filter category"]
        XCTAssertTrue(looks.waitForExistence(timeout: 3))
        looks.tap()

        let tray = app.scrollViews["looks-tray"]
        XCTAssertTrue(tray.waitForExistence(timeout: 3))

        let sundayBest = app.buttons["Sunday Best, look"]
        XCTAssertTrue(sundayBest.waitForExistence(timeout: 3))
        sundayBest.tap()

        let trayDismissed = NSPredicate(format: "exists == false")
        expectation(for: trayDismissed, evaluatedWith: tray)
        waitForExpectations(timeout: 3)
    }

}

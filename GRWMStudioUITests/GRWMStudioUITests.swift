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
}

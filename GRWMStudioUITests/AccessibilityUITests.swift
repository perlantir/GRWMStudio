import XCTest

@MainActor
final class AccessibilityUITests: XCTestCase {
    @MainActor
    func testCaptureAccessibilityVisualEvidence() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-GRWMDebugAppShell",
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXXL"
        ]
        app.launch()

        let capture = app.buttons["capture-fab"]
        XCTAssertTrue(capture.waitForExistence(timeout: 8))
        try saveScreenshot(named: "error-no-face-ax2")

        if app.buttons["Got It"].exists {
            app.buttons["Got It"].tap()
        } else if app.buttons["error-close"].exists {
            app.buttons["error-close"].tap()
        }

        let skin = app.buttons["Skin filter category"]
        XCTAssertTrue(skin.waitForExistence(timeout: 8))
        try saveScreenshot(named: "mirror-default-ax2")

        skin.tap()

        let fair = app.buttons["Fair Skin shade"]
        XCTAssertTrue(fair.waitForExistence(timeout: 3))
        try saveScreenshot(named: "skin-tray-ax2")
        fair.tap()

        let feed = app.buttons["tab-feed"]
        XCTAssertTrue(feed.waitForExistence(timeout: 3))
        feed.tap()
        XCTAssertEqual(feed.value as? String, "Selected")
        try saveScreenshot(named: "feed-ax2")
    }

    @MainActor
    func testCaptureAccessibilityFollowsPhotoAndVideoModes() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell"]
        app.launch()

        let capture = app.buttons["capture-fab"]
        XCTAssertTrue(capture.waitForExistence(timeout: 8))
        XCTAssertEqual(capture.label, "Capture button")
        XCTAssertEqual(capture.value as? String, "Take photo")

        let videoMode = app.buttons["Video capture mode"]
        XCTAssertTrue(videoMode.waitForExistence(timeout: 3))
        videoMode.tap()

        XCTAssertEqual(capture.value as? String, "Start video")
    }

    @MainActor
    func testShadeTrayAccessibilityIncludesOrdinalAndSelectedState() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell"]
        app.launch()

        let skin = app.buttons["Skin filter category"]
        XCTAssertTrue(skin.waitForExistence(timeout: 8))
        skin.tap()

        let fair = app.buttons["Fair Skin shade"]
        XCTAssertTrue(fair.waitForExistence(timeout: 3))
        XCTAssertEqual(fair.value as? String, "1 of 6")

        fair.tap()
        skin.tap()

        let selectedFair = app.buttons["Fair Skin shade"]
        XCTAssertTrue(selectedFair.waitForExistence(timeout: 3))
        XCTAssertEqual(selectedFair.value as? String, "1 of 6, Selected")
    }

    @MainActor
    func testTabBarAccessibilityValueTracksSelectedState() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell"]
        app.launch()

        let mirror = app.buttons["tab-mirror"]
        let feed = app.buttons["tab-feed"]
        XCTAssertTrue(mirror.waitForExistence(timeout: 8))
        XCTAssertEqual(mirror.value as? String, "Selected")

        feed.tap()

        XCTAssertEqual(feed.value as? String, "Selected")
        XCTAssertEqual(mirror.value as? String, "Not selected")
    }

    @MainActor
    func testKeyControlsMeetMinimum44PointHitTargets() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell"]
        app.launch()

        let capture = app.buttons["capture-fab"]
        let favoriteLooks = app.buttons["favorite-looks-button"]
        let photoMode = app.buttons["Photo capture mode"]
        XCTAssertTrue(capture.waitForExistence(timeout: 8))
        XCTAssertTrue(favoriteLooks.exists)
        XCTAssertTrue(photoMode.waitForExistence(timeout: 3))

        assertMinimumHitTarget(capture, name: "capture")
        assertMinimumHitTarget(favoriteLooks, name: "favorite looks")
        assertMinimumHitTarget(photoMode, name: "photo mode")

        capture.tap()

        let discard = app.buttons["preview-discard-button"]
        let save = app.buttons["Save to Locker"]
        let share = app.buttons["Share"]
        XCTAssertTrue(discard.waitForExistence(timeout: 5))

        assertMinimumHitTarget(discard, name: "preview discard")
        assertMinimumHitTarget(save, name: "save")
        assertMinimumHitTarget(share, name: "share")
    }

    private func assertMinimumHitTarget(_ element: XCUIElement, name: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertGreaterThanOrEqual(element.frame.width, 44, "\(name) width below 44pt: \(element.frame.width)", file: file, line: line)
        XCTAssertGreaterThanOrEqual(element.frame.height, 44, "\(name) height below 44pt: \(element.frame.height)", file: file, line: line)
    }

    private func saveScreenshot(named name: String, file: StaticString = #filePath) throws {
        let root = URL(fileURLWithPath: "\(file)")
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let directory = root.appendingPathComponent("docs/qa/per-ticket/GRWM-853", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let screenshotURL = directory.appendingPathComponent("\(name).png")
        try XCUIScreen.main.screenshot().pngRepresentation.write(to: screenshotURL)
    }
}

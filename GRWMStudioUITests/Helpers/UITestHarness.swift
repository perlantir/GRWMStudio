import XCTest

@MainActor
enum UITestHarness {
    static func boot(
        startTab: String = "Mirror",
        resetState: Bool = true,
        extraArguments: [String] = []
    ) -> XCUIApplication {
        let app = XCUIApplication()
        var arguments = ["-GRWMDebugAppShell", "-GRWMDebugStart\(startTab)"]
        if resetState {
            arguments.append("-GRWMUITestResetState")
        }
        arguments.append(contentsOf: extraArguments)
        app.launchArguments = arguments
        app.launch()
        return app
    }

    static func bootWithDeniedCamera() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell", "-GRWMDebugCameraDenied", "-GRWMDebugStartMirror"]
        app.launch()
        return app
    }
}

@MainActor
struct TabBarPage {
    let app: XCUIApplication

    func tapMirror() {
        app.buttons["tab-mirror"].tap()
    }

    func tapLooks() {
        app.buttons["tab-looks"].tap()
    }

    func tapFeed() {
        app.buttons["tab-feed"].tap()
    }

    func tapLocker() {
        app.buttons["tab-locker"].tap()
    }
}

@MainActor
struct MirrorPage {
    let app: XCUIApplication

    func expectReady(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(app.buttons["capture-fab"].waitForExistence(timeout: 8), file: file, line: line)
    }

    func selectCategory(_ name: String, file: StaticString = #filePath, line: UInt = #line) {
        let button = app.buttons["\(name) filter category"]
        scrollUntilHittable(button, within: app.scrollViews["filter-rail"], file: file, line: line)
        button.tap()
    }

    func selectShade(_ shadeName: String, category: String, file: StaticString = #filePath, line: UInt = #line) {
        let shade = app.buttons["\(shadeName) \(category) shade"]
        scrollUntilHittable(shade, within: app.scrollViews["shade-tray-\(category.lowercased())"], file: file, line: line)
        shade.tap()
    }

    func selectEyeSubcategory(_ name: String, file: StaticString = #filePath, line: UInt = #line) {
        let subcategory = app.buttons["eyes-subcategory-\(name.lowercased())"]
        XCTAssertTrue(subcategory.waitForExistence(timeout: 5), "Missing eye subcategory \(name)", file: file, line: line)
        subcategory.tap()
    }

    func capturePhoto(file: StaticString = #filePath, line: UInt = #line) {
        let capture = app.buttons["capture-fab"]
        XCTAssertTrue(capture.waitForExistence(timeout: 8), file: file, line: line)
        capture.tap()
    }

    func recordShortVideo(file: StaticString = #filePath, line: UInt = #line) {
        let videoMode = app.buttons["Video capture mode"]
        XCTAssertTrue(videoMode.waitForExistence(timeout: 8), file: file, line: line)
        videoMode.tap()

        app.buttons["capture-fab"].tap()
        let stop = app.buttons["recording-stop-chip"]
        XCTAssertTrue(stop.waitForExistence(timeout: 5), file: file, line: line)
        stop.tap()
    }

    private func scrollUntilHittable(
        _ element: XCUIElement,
        within scrollView: XCUIElement,
        file: StaticString,
        line: UInt
    ) {
        XCTAssertTrue(element.waitForExistence(timeout: 8), "Missing \(element)", file: file, line: line)

        for _ in 0..<5 where !isVisible(element) {
            if scrollView.exists {
                scrollView.swipeLeft()
            } else {
                app.swipeLeft()
            }
        }

        XCTAssertTrue(isVisible(element), "Element is off-screen or blocked: \(element)", file: file, line: line)
    }

    private func isVisible(_ element: XCUIElement) -> Bool {
        guard element.exists, !element.frame.isEmpty else {
            return false
        }

        return app.frame.insetBy(dx: 4, dy: 4).contains(
            CGPoint(x: element.frame.midX, y: element.frame.midY)
        )
    }
}

@MainActor
struct PreviewPage {
    let app: XCUIApplication

    func expectVisible(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(app.staticTexts["Preview"].waitForExistence(timeout: 8), file: file, line: line)
    }

    func saveToLocker(file: StaticString = #filePath, line: UInt = #line) {
        let save = app.buttons["Save to Locker"]
        XCTAssertTrue(save.waitForExistence(timeout: 8), file: file, line: line)
        save.tap()
    }

    func discardIfVisible() {
        let discard = app.buttons["preview-discard-button"]
        if discard.exists {
            discard.tap()
        }
    }
}

@MainActor
struct LockerPage {
    let app: XCUIApplication

    func expectVisible(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(app.staticTexts["GRWM Star"].waitForExistence(timeout: 8), file: file, line: line)
    }

    func openSettings(file: StaticString = #filePath, line: UInt = #line) {
        let settings = app.buttons["locker-settings-button"]
        XCTAssertTrue(settings.waitForExistence(timeout: 8), file: file, line: line)
        settings.tap()
    }
}

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

        XCTAssertTrue(app.staticTexts["Preview"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["preview-discard-button"].exists)
        XCTAssertTrue(app.buttons["Unmute video preview"].exists || app.buttons["Mute video preview"].exists)
        XCTAssertTrue(app.buttons["Save to Locker"].exists)

        app.buttons["preview-discard-button"].tap()

        XCTAssertFalse(app.staticTexts["Preview"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["Skin filter category"].exists)
    }

    @MainActor
    func testVideoPreviewPlaybackControlToggles() throws {
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

        XCTAssertTrue(app.staticTexts["Preview"].waitForExistence(timeout: 5))

        let unmute = app.buttons["Unmute video preview"]
        XCTAssertTrue(unmute.waitForExistence(timeout: 3))
        unmute.tap()
        XCTAssertTrue(app.buttons["Mute video preview"].waitForExistence(timeout: 2))

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "video-preview-muted-control"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testPhotoPreviewLayoutControlsVisible() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell"]
        app.launch()

        let capture = app.buttons["capture-fab"]
        XCTAssertTrue(capture.waitForExistence(timeout: 8))
        capture.tap()

        XCTAssertTrue(app.staticTexts["Preview"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["preview-discard-button"].exists)
        XCTAssertTrue(app.buttons["Save to Locker"].exists)
        XCTAssertTrue(app.buttons["Share"].exists)
        XCTAssertTrue(app.staticTexts["Custom mix"].exists)

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "photo-preview-layout-controls"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testPhotoPreviewSaveShowsConfettiAndReturnsMirror() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell"]
        app.launch()

        let capture = app.buttons["capture-fab"]
        XCTAssertTrue(capture.waitForExistence(timeout: 8))
        capture.tap()

        let save = app.buttons["Save to Locker"]
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        save.tap()

        XCTAssertTrue(app.staticTexts["Saved! 💖"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Preview"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Skin filter category"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testPhotoPreviewSaveFailureShowsInlineBanner() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell", "-GRWMDebugSaveFail"]
        app.launch()

        let capture = app.buttons["capture-fab"]
        XCTAssertTrue(capture.waitForExistence(timeout: 8))
        capture.tap()

        let save = app.buttons["Save to Locker"]
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        save.tap()

        XCTAssertTrue(app.staticTexts["Saving needs a reset."].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Preview"].exists)
        XCTAssertTrue(app.buttons["Save to Locker"].exists)
    }

    @MainActor
    func testFavoriteLooksButtonRoutesToLooksTab() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell"]
        app.launch()

        let favoriteLooks = app.buttons["favorite-looks-button"]
        XCTAssertTrue(favoriteLooks.waitForExistence(timeout: 8))
        favoriteLooks.tap()

        XCTAssertTrue(app.staticTexts["Looks Library - wired in GRWM-500"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Looks"].isSelected)
    }

    @MainActor
    func testRecordingOverlayHidesMirrorControls() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell", "-GRWMDebugCaptureRecording"]
        app.launch()

        XCTAssertTrue(app.otherElements["recording-overlay"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["recording-elapsed-label"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["recording-elapsed-label"].label, "0:05")
        XCTAssertTrue(app.buttons["recording-stop-chip"].exists)
        XCTAssertFalse(app.scrollViews["filter-rail"].exists)
        XCTAssertFalse(app.buttons["Flip camera"].exists)

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "recording-overlay"
        attachment.lifetime = .keepAlways
        add(attachment)
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

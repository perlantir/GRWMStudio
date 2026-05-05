import XCTest

final class SettingsPolishUITests: XCTestCase {
    @MainActor
    func testSettingsLookAndFeelShowsSeparateSoundAndHapticsRows() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell"]
        app.launch()

        let locker = app.buttons["tab-locker"]
        XCTAssertTrue(locker.waitForExistence(timeout: 8))
        locker.tap()

        let settings = app.buttons["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 8))
        settings.tap()

        let lookAndFeel = app.staticTexts["Look & Feel"]
        for _ in 0..<6 where !(lookAndFeel.exists && lookAndFeel.isHittable) {
            app.swipeUp()
        }

        XCTAssertTrue(lookAndFeel.waitForExistence(timeout: 5))
        XCTAssertTrue(lookAndFeel.isHittable)
        XCTAssertTrue(app.staticTexts["Theme"].exists)
        XCTAssertTrue(app.staticTexts["Sounds"].exists)
        XCTAssertTrue(app.staticTexts["Haptics"].exists)

        app.swipeUp()

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "settings-look-and-feel"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testLockedStudioProFromSettingsPresentsParentGateAndPaywall() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-GRWMDebugAppShell",
            "-GRWMDebugParentGateMath"
        ]
        app.launch()

        let locker = app.buttons["tab-locker"]
        XCTAssertTrue(locker.waitForExistence(timeout: 8))
        locker.tap()

        let settings = app.buttons["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 8))
        settings.tap()

        let lockedStudioPro = app.buttons["Studio Pro. Locked"].firstMatch
        XCTAssertTrue(lockedStudioPro.waitForExistence(timeout: 8))
        lockedStudioPro.tap()

        XCTAssertTrue(app.staticTexts["Quick grown-up check"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["GROWN-UPS ONLY"].exists)

        app.buttons["parent-gate-digit-1"].tap()
        app.buttons["parent-gate-digit-7"].tap()
        app.buttons["parent-gate-okay"].tap()

        XCTAssertTrue(app.staticTexts["Unlock"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["More looks, more shades, more sparkle."].exists)

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "settings-studio-pro-parent-gate-paywall"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

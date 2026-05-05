import Foundation
import XCTest

@MainActor
final class ErrorScreenshotsUITests: XCTestCase {
    private let variants: [(slug: String, chip: String)] = [
        ("cam-denied", "CAM-DENIED issue"),
        ("mic-denied", "MIC-DENIED issue"),
        ("photo-denied", "PHOTO-DENIED issue"),
        ("license", "LICENSE issue"),
        ("effect-fail", "EFFECT-FAIL issue"),
        ("rec-fail", "REC-FAIL issue"),
        ("save-fail", "SAVE-FAIL issue"),
        ("no-face", "NO-FACE issue"),
        ("low-storage", "LOW-STORAGE issue")
    ]

    @MainActor
    func testCaptureAllErrorScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-GRWMDebugAppShell"]
        app.launch()

        let locker = app.buttons["tab-locker"]
        XCTAssertTrue(locker.waitForExistence(timeout: 8))
        locker.tap()

        let settings = app.buttons["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 8))
        settings.tap()

        openErrorTrigger(in: app)

        for variant in variants {
            let trigger = app.buttons["error-trigger-\(variant.slug)"]
            XCTAssertTrue(trigger.waitForExistence(timeout: 5), "Missing trigger for \(variant.slug)")
            trigger.tap()

            let chip = app.staticTexts[variant.chip]
            XCTAssertTrue(chip.waitForExistence(timeout: 5), "Missing chip for \(variant.slug)")
            XCTAssertTrue(app.buttons["error-close"].waitForExistence(timeout: 5), "Missing error close for \(variant.slug)")

            saveScreenshot(named: variant.slug)

            app.buttons["error-close"].tap()
        }
    }

    private func saveScreenshot(named slug: String) {
        autoreleasepool {
            let screenshot = XCUIScreen.main.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = slug
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }

    private func openErrorTrigger(in app: XCUIApplication) {
        let errorTrigger = app.buttons
            .matching(NSPredicate(format: "label BEGINSWITH %@", "Error Trigger"))
            .firstMatch
        for _ in 0..<8 where !errorTrigger.exists {
            app.swipeUp()
        }
        XCTAssertTrue(errorTrigger.waitForExistence(timeout: 8))
        errorTrigger.tap()
    }
}

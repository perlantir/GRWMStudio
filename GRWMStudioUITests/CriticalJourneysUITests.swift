import XCTest

@MainActor
final class CriticalJourneysUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testJourney1MirrorPhotoSaveLocker() {
        let app = UITestHarness.boot()
        let mirror = MirrorPage(app: app)

        mirror.expectReady()
        mirror.selectCategory("Skin")
        mirror.selectShade("Fair", category: "Skin")
        mirror.capturePhoto()

        let preview = PreviewPage(app: app)
        preview.expectVisible()
        preview.saveToLocker()

        XCTAssertTrue(app.otherElements["saved-confetti"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["saved-confetti"].waitForNonExistence(timeout: 3))
        TabBarPage(app: app).tapLocker()
        LockerPage(app: app).expectVisible()
    }

    func testJourney2SwapShadesAcrossPrimaryCategories() {
        let app = UITestHarness.boot()
        let mirror = MirrorPage(app: app)

        mirror.expectReady()
        mirror.selectCategory("Skin")
        mirror.selectShade("Light", category: "Skin")
        mirror.selectCategory("Base")
        mirror.selectShade("Soft", category: "Base")
        mirror.selectCategory("Eyes")
        mirror.selectShade("Pink", category: "Eyes")
        mirror.selectCategory("Lips")
        mirror.selectShade("Classic Red", category: "Lips")

        XCTAssertFalse(app.staticTexts["EFFECT-FAIL issue"].exists)
    }

    func testJourney3ProShadeRoutesToLicenseError() {
        let app = UITestHarness.boot()
        let mirror = MirrorPage(app: app)

        mirror.expectReady()
        mirror.selectCategory("Eyes")
        mirror.selectEyeSubcategory("Liner")
        mirror.selectShade("Winged", category: "Eyes")

        XCTAssertTrue(app.staticTexts["error-chip-license"].waitForExistence(timeout: 5))
    }

    func testJourney4VideoPreviewSaveLocker() {
        let app = UITestHarness.boot()
        let mirror = MirrorPage(app: app)

        mirror.expectReady()
        mirror.recordShortVideo()

        let preview = PreviewPage(app: app)
        preview.expectVisible()
        XCTAssertTrue(app.buttons["preview-video-audio-toggle"].exists)
        preview.saveToLocker()

        XCTAssertTrue(app.otherElements["saved-confetti"].waitForExistence(timeout: 5))
    }

    func testJourney5CameraDeniedShowsDisabledMirror() {
        let app = UITestHarness.bootWithDeniedCamera()

        XCTAssertTrue(app.staticTexts["error-chip-cam-denied"].waitForExistence(timeout: 8))
        app.buttons["error-alt-cam-denied"].tap()
        XCTAssertTrue(app.buttons["mirror-permission-card"].waitForExistence(timeout: 5))
    }

    func testJourney6LooksProLookRoutesToParentGate() {
        let app = UITestHarness.boot(startTab: "Looks", extraArguments: ["-GRWMDebugParentGateMath"])

        let proLook = app.buttons["look-card-look.pop-star"]
        XCTAssertTrue(proLook.waitForExistence(timeout: 8))
        proLook.tap()

        let primaryAction = app.buttons["look-detail-primary-action"]
        XCTAssertTrue(primaryAction.waitForExistence(timeout: 8))
        primaryAction.tap()

        XCTAssertTrue(app.staticTexts["Quick grown-up check"].waitForExistence(timeout: 5))
    }

    func testJourney7LockerSettingsEntryAndDeleteModeBanner() {
        let app = UITestHarness.boot(startTab: "Locker")
        let locker = LockerPage(app: app)

        locker.expectVisible()
        locker.openSettings()
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 8))
    }

    func testJourney8SoundTogglePersistsThroughMirrorReturn() {
        let app = UITestHarness.boot(startTab: "Locker")
        let locker = LockerPage(app: app)

        locker.expectVisible()
        locker.openSettings()
        let sounds = app.buttons["settings-sounds-toggle"]
        for _ in 0..<8 where !sounds.exists {
            app.swipeUp()
        }
        XCTAssertTrue(sounds.waitForExistence(timeout: 8))
        let initialValue = sounds.value as? String
        sounds.tap()

        app.buttons["Back"].tap()
        TabBarPage(app: app).tapMirror()
        MirrorPage(app: app).expectReady()

        TabBarPage(app: app).tapLocker()
        LockerPage(app: app).openSettings()
        for _ in 0..<8 where !sounds.exists {
            app.swipeUp()
        }
        XCTAssertNotEqual(sounds.value as? String, initialValue)
    }
}

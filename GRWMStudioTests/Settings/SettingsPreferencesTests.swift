@testable import GRWMStudio
import XCTest

final class SettingsPreferencesTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetKeys()
    }

    override func tearDown() {
        resetKeys()
        super.tearDown()
    }

    func testDefaultsMatchKidsSafeConfiguration() {
        XCTAssertFalse(SettingsPreferences.saveToPhotos)
        XCTAssertTrue(SettingsPreferences.blockShareExtensions)
        XCTAssertTrue(SettingsPreferences.soundEnabled)
        XCTAssertTrue(SettingsPreferences.hapticsEnabled)
    }

    func testPreferenceSettersPersistValues() {
        SettingsPreferences.saveToPhotos = true
        SettingsPreferences.blockShareExtensions = false
        SettingsPreferences.soundEnabled = false
        SettingsPreferences.hapticsEnabled = false

        XCTAssertTrue(SettingsPreferences.saveToPhotos)
        XCTAssertFalse(SettingsPreferences.blockShareExtensions)
        XCTAssertFalse(SettingsPreferences.soundEnabled)
        XCTAssertFalse(SettingsPreferences.hapticsEnabled)
    }

    func testLegacyCombinedPreferenceFeedsNewTogglesUntilSplitKeysAreSet() {
        UserDefaults.standard.set(false, forKey: SettingsPreferences.legacySoundsHapticsKey)

        XCTAssertFalse(SettingsPreferences.soundEnabled)
        XCTAssertFalse(SettingsPreferences.hapticsEnabled)

        SettingsPreferences.hapticsEnabled = true

        XCTAssertFalse(SettingsPreferences.soundEnabled)
        XCTAssertTrue(SettingsPreferences.hapticsEnabled)
    }

    private func resetKeys() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: SettingsPreferences.saveToPhotosKey)
        defaults.removeObject(forKey: SettingsPreferences.blockShareExtensionsKey)
        defaults.removeObject(forKey: SettingsPreferences.soundEnabledKey)
        defaults.removeObject(forKey: SettingsPreferences.hapticsEnabledKey)
        defaults.removeObject(forKey: SettingsPreferences.legacySoundsHapticsKey)
    }
}

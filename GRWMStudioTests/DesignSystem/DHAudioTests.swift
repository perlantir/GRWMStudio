@testable import GRWMStudio
import XCTest

final class DHAudioTests: XCTestCase {
    func testAllDeclaredSoundsHaveBundledMP3AssetsUnderSizeBudget() throws {
        for sound in DHSound.allCases {
            let url = try XCTUnwrap(sound.url, "Missing bundled audio asset for \(sound.rawValue)")
            XCTAssertEqual(url.pathExtension, "mp3")

            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = try XCTUnwrap(attributes[.size] as? NSNumber).intValue
            XCTAssertLessThanOrEqual(fileSize, 80 * 1_024, "\(sound.rawValue).mp3 is over the 80KB budget")
        }
    }

    @MainActor
    func testAudioPlayRespectsSoundPreferenceWhenDisabled() {
        let previous = SettingsPreferences.soundEnabled
        SettingsPreferences.soundEnabled = false
        defer { SettingsPreferences.soundEnabled = previous }

        DHAudio.shared.play(.tapSoft)
    }
}

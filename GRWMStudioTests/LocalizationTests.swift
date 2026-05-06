@testable import GRWMStudio
import XCTest

final class LocalizationTests: XCTestCase {
    func testRequiredEnglishKeysExistInStringCatalog() throws {
        let keys = try stringCatalogKeys()
        let required: Set<String> = [
            "feed.title",
            "feed.empty.title",
            "locker.title",
            "mirror.category.eyes",
            "mirror.permission.title",
            "paywall.title_prefix",
            "preview.title",
            "settings.title",
            "errors.cam_denied.title",
            "errors.effect_fail.title"
        ]

        for key in required {
            XCTAssertTrue(keys.contains(key), "Missing localized key: \(key)")
        }
    }

    func testStringCatalogHasNoEmptyEnglishValuesForRequiredKeys() throws {
        let strings = try stringCatalogStrings()
        for key in try stringCatalogKeys() where key.hasPrefix("mirror.") || key.hasPrefix("error.") {
            guard let entry = strings[key] as? [String: Any],
                  let localizations = entry["localizations"] as? [String: Any],
                  let english = localizations["en"] as? [String: Any],
                  let unit = english["stringUnit"] as? [String: Any],
                  let value = unit["value"] as? String else {
                continue
            }
            XCTAssertFalse(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Empty English value: \(key)")
        }
    }

    private func stringCatalogKeys() throws -> Set<String> {
        Set(try stringCatalogStrings().keys)
    }

    private func stringCatalogStrings() throws -> [String: Any] {
        let url = repoRoot.appendingPathComponent("GRWMStudio/Resources/Localizable.xcstrings")
        let data = try Data(contentsOf: url)
        let root = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        return try XCTUnwrap(root["strings"] as? [String: Any])
    }

    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

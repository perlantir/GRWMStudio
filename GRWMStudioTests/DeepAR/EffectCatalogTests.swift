@testable import GRWMStudio
import XCTest

@MainActor
final class EffectCatalogTests: XCTestCase {
    func testManifestLoads() async throws {
        let root = try await EffectCatalog.shared.load()

        XCTAssertEqual(root.version, 1)
        XCTAssertNotNil(root.effects[MakeupCategory.skin.id])
    }

    func testAllCategoriesHaveAtLeastOneEffect() async throws {
        let root = try await EffectCatalog.shared.load()

        for category in MakeupCategory.allCases {
            let effects = root.effects[category.id] ?? []
            XCTAssertFalse(effects.isEmpty, "Missing effects for category \(category.id)")
        }
    }

    func testManifestContainsStarterEffectSet() async throws {
        let root = try await EffectCatalog.shared.load()

        XCTAssertEqual(root.effects["skin"]?.first(where: { $0.id == "baseBeauty" })?.shades.count, 5)

        let baseEffect = root.effects["base"]?.first(where: { $0.id == "noFilter" })
        XCTAssertNotNil(baseEffect)
        XCTAssertNotNil(baseEffect?.shades.first(where: { $0.id == "bright" }))

        let eyes = root.effects["eyes"] ?? []
        XCTAssertEqual(eyes.first(where: { $0.id == "shadow" })?.shades.count, 5)
        XCTAssertNotNil(eyes.first(where: { $0.id == "eyeliner" }))

        XCTAssertEqual(root.effects["lips"]?.first(where: { $0.id == "lips" })?.shades.count, 5)
        XCTAssertNotNil(root.effects["looks"]?.first(where: { $0.id == "look1" }))
        XCTAssertNotNil(root.effects["looks"]?.first(where: { $0.id == "look2" }))
    }

    func testContainsSyncUsesManifestEffectIdentifiers() {
        XCTAssertTrue(EffectCatalog.shared.containsSync(effectID: "baseBeauty"))
        XCTAssertFalse(EffectCatalog.shared.containsSync(effectID: "brows"))
        XCTAssertFalse(EffectCatalog.shared.containsSync(effectID: "blush"))
    }

    func testEveryParameterRefResolves() async throws {
        let root = try await EffectCatalog.shared.load()

        for (_, effects) in root.effects {
            for effect in effects {
                for shade in effect.shades {
                    for parameter in shade.parameters {
                        XCTAssertNotNil(
                            EffectParameterMap.resolve(parameter.ref),
                            "Unresolved ref: \(parameter.ref) in shade \(shade.id)"
                        )
                    }
                }
            }
        }
    }

    func testEffectFilesExist() async throws {
        let root = try await EffectCatalog.shared.load()

        for (_, effects) in root.effects {
            for effect in effects {
                XCTAssertNoThrow(try effect.bundleURL(), "Missing bundle file: \(effect.file)")
            }
        }
    }

    func testThumbnailsExist() async throws {
        let root = try await EffectCatalog.shared.load()

        for (_, effects) in root.effects {
            for effect in effects {
                XCTAssertNotNil(thumbnailURL(for: effect), "Missing thumbnail: \(effect.thumbnail)")
            }
        }
    }

    func testProShadeFlagsExistForRowsWithPremiumContent() async throws {
        let root = try await EffectCatalog.shared.load()
        let rows = ["skin": "baseBeauty", "base": "noFilter", "eyes": "shadow", "lips": "lips"]

        for (category, effectID) in rows {
            let effect = root.effects[category]?.first(where: { $0.id == effectID })
            XCTAssertTrue(effect?.shades.contains(where: { $0.isPro == true }) == true, "Missing pro shade in \(effectID)")
        }
    }

    private func thumbnailURL(for effect: EffectFile) -> URL? {
        let path = effect.thumbnail as NSString
        let stem = path.deletingPathExtension
        let ext = path.pathExtension
        return Bundle.main.url(forResource: stem, withExtension: ext, subdirectory: "Effects")
    }
}

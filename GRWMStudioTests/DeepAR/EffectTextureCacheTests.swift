@testable import GRWMStudio
import UIKit
import XCTest

@MainActor
final class EffectTextureCacheTests: XCTestCase {
    func testCacheReturnsLoadedImageAndEvictsLeastRecentlyUsedEntry() async {
        let cache = EffectTextureCache(limit: 2)
        let first = UIImage()
        let second = UIImage()
        let third = UIImage()

        _ = await cache.image(for: "one") { first }
        _ = await cache.image(for: "two") { second }
        _ = await cache.image(for: "one") { UIImage?.none }
        _ = await cache.image(for: "three") { third }

        let retainedFirst = await cache.image(for: "one") { UIImage?.none }
        let evictedSecond = await cache.image(for: "two") { UIImage?.none }
        let retainedThird = await cache.image(for: "three") { UIImage?.none }

        XCTAssertTrue(retainedFirst === first)
        XCTAssertNil(evictedSecond)
        XCTAssertTrue(retainedThird === third)
        XCTAssertEqual(cache.count, 2)
    }

    func testRemoveAllClearsCachedImages() async {
        let cache = EffectTextureCache(limit: 2)
        _ = await cache.image(for: "one") { UIImage() }
        _ = await cache.image(for: "two") { UIImage() }

        cache.removeAll()

        XCTAssertEqual(cache.count, 0)
        let reloaded = await cache.image(for: "one") { UIImage?.none }
        XCTAssertNil(reloaded)
    }
}

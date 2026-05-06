@testable import GRWMStudio
import XCTest

@MainActor
final class ProEntitlementsTests: XCTestCase {
    func testInitialStateReadsCachedDefault() {
        let defaults = Self.defaults()
        defaults.set(true, forKey: ProEntitlements.cacheKey)

        let entitlements = ProEntitlements(defaults: defaults, autoRefresh: false, store: FakeProPurchaseStateStore())

        XCTAssertTrue(entitlements.isPro)
    }

    func testRefreshSetsAuthoritativeProAndCachesIt() async {
        let defaults = Self.defaults()
        let store = FakeProPurchaseStateStore(currentValue: true)
        let entitlements = ProEntitlements(defaults: defaults, autoRefresh: false, store: store)

        await entitlements.refresh()

        XCTAssertTrue(entitlements.isPro)
        XCTAssertTrue(defaults.bool(forKey: ProEntitlements.cacheKey))
    }

    func testRefreshClearsStaleCachedPro() async {
        let defaults = Self.defaults()
        defaults.set(true, forKey: ProEntitlements.cacheKey)
        let store = FakeProPurchaseStateStore(currentValue: false)
        let entitlements = ProEntitlements(defaults: defaults, autoRefresh: false, store: store)

        await entitlements.refresh()

        XCTAssertFalse(entitlements.isPro)
        XCTAssertFalse(defaults.bool(forKey: ProEntitlements.cacheKey))
    }

    func testPurchaseUpdateStreamUpdatesCache() async throws {
        let defaults = Self.defaults()
        let store = FakeProPurchaseStateStore(currentValue: false)
        let entitlements = ProEntitlements(defaults: defaults, autoRefresh: true, store: store)

        store.sendUpdate(true)
        try await waitUntil { entitlements.isPro }

        XCTAssertTrue(defaults.bool(forKey: ProEntitlements.cacheKey))
    }

    private static func defaults() -> UserDefaults {
        let suiteName = "app.grwmstudio.tests.pro.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    private func waitUntil(
        _ condition: @MainActor @escaping () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        for _ in 0..<20 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertTrue(condition(), file: file, line: line)
    }
}

@MainActor
private final class FakeProPurchaseStateStore: ProPurchaseStateStoring {
    var currentValue: Bool
    private var continuation: AsyncStream<Bool>.Continuation?

    init(currentValue: Bool = false) {
        self.currentValue = currentValue
    }

    func currentIsPro() async -> Bool {
        currentValue
    }

    func proPurchaseUpdates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }

    func sendUpdate(_ isPro: Bool) {
        continuation?.yield(isPro)
    }
}

@testable import GRWMStudio
import XCTest

@MainActor
final class OnboardingStateTests: XCTestCase {
    private let suiteName = "app.grwmstudio.tests.onboarding"

    override func setUp() {
        super.setUp()
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testCompletionPersistsUnderExpectedKey() throws {
        let defaults = try makeDefaults()
        let state = OnboardingState(defaults: defaults)

        XCTAssertFalse(state.hasCompletedOnboarding)

        state.hasCompletedOnboarding = true

        XCTAssertTrue(defaults.bool(forKey: "dh_onboarding_complete"))
        XCTAssertTrue(OnboardingState(defaults: defaults).hasCompletedOnboarding)
    }

    func testResetRemovesCompletionFlag() throws {
        let defaults = try makeDefaults()
        let state = OnboardingState(defaults: defaults)
        state.hasCompletedOnboarding = true

        state.reset()

        XCTAssertFalse(state.hasCompletedOnboarding)
        XCTAssertNil(defaults.object(forKey: "dh_onboarding_complete"))
    }

    func testCoordinatorCompleteOnboardingStoresFlagAndRoutesToApp() throws {
        let defaults = try makeDefaults()
        let state = OnboardingState(defaults: defaults)
        let environment = AppEnvironment(onboarding: state)
        let coordinator = RootCoordinator()

        coordinator.completeOnboarding(env: environment)

        XCTAssertTrue(state.hasCompletedOnboarding)
        XCTAssertEqual(coordinator.route, .app)
    }

    func testCoordinatorParentGatePaywallOverlaySequencePreservesAppRoute() {
        let coordinator = RootCoordinator()
        coordinator.route = .app

        coordinator.startParentGate(intent: .paywall)

        XCTAssertEqual(coordinator.route, .app)
        XCTAssertEqual(coordinator.overlay, .parentGate(intent: .paywall))

        coordinator.paywallShown()

        XCTAssertEqual(coordinator.route, .app)
        XCTAssertEqual(coordinator.overlay, .paywall)

        coordinator.dismissOverlay()

        XCTAssertEqual(coordinator.route, .app)
        XCTAssertNil(coordinator.overlay)
    }

    private func makeDefaults() throws -> UserDefaults {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}

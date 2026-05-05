@testable import GRWMStudio
import UIKit
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

    func testCoordinatorParentGatePaywallPresentationPreservesAppRoute() async throws {
        let coordinator = RootCoordinator()
        coordinator.route = .app

        coordinator.startParentGate(intent: .paywall(source: .proShade))

        XCTAssertEqual(coordinator.route, .app)
        XCTAssertEqual(coordinator.presentedParentGate, .paywall(source: .proShade))
        XCTAssertNil(coordinator.presentedPaywallSource)

        coordinator.parentGatePassed(.paywall(source: .proShade))

        XCTAssertEqual(coordinator.route, .app)
        XCTAssertNil(coordinator.presentedParentGate)
        try await Task.sleep(for: .milliseconds(350))
        XCTAssertEqual(coordinator.presentedPaywallSource, .proShade)

        coordinator.dismissPaywall()

        XCTAssertEqual(coordinator.route, .app)
        XCTAssertNil(coordinator.presentedPaywallSource)
    }

    func testCoordinatorPreviewOverlayPreservesAppRouteAndDismisses() {
        let coordinator = RootCoordinator()
        coordinator.route = .app

        coordinator.showPreview(asset: .photo(Self.testImage()))

        XCTAssertEqual(coordinator.route, .app)
        XCTAssertEqual(coordinator.overlay, .preview)
        XCTAssertNotNil(coordinator.previewAsset)
        XCTAssertNil(coordinator.previewLookName)
        XCTAssertTrue(coordinator.previewShadeIDs.isEmpty)

        coordinator.dismissPreview()

        XCTAssertEqual(coordinator.route, .app)
        XCTAssertNil(coordinator.overlay)
        XCTAssertNil(coordinator.previewAsset)
        XCTAssertNil(coordinator.previewLookName)
        XCTAssertTrue(coordinator.previewShadeIDs.isEmpty)
    }

    func testCoordinatorPreviewStoresLookName() {
        let coordinator = RootCoordinator()

        coordinator.showPreview(
            asset: .photo(Self.testImage()),
            lookName: "Sunday Best",
            shadeIDs: ["lip.classic-red"]
        )

        XCTAssertEqual(coordinator.overlay, .preview)
        XCTAssertEqual(coordinator.previewLookName, "Sunday Best")
        XCTAssertEqual(coordinator.previewShadeIDs, ["lip.classic-red"])
    }

    func testCoordinatorSavedPreviewShowsConfettiThenFinishes() {
        let coordinator = RootCoordinator()
        coordinator.route = .app
        coordinator.showPreview(asset: .photo(Self.testImage()), lookName: "Sunday Best", shadeIDs: ["lip.classic-red"])

        coordinator.dismissPreviewSaved()

        XCTAssertEqual(coordinator.route, .app)
        XCTAssertEqual(coordinator.overlay, .savedConfetti)
        XCTAssertNil(coordinator.previewAsset)
        XCTAssertNil(coordinator.previewLookName)
        XCTAssertTrue(coordinator.previewShadeIDs.isEmpty)

        coordinator.finishPreviewSaved()

        XCTAssertNil(coordinator.overlay)
    }

    private func makeDefaults() throws -> UserDefaults {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    private static func testImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { context in
            UIColor.systemPink.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        }
    }
}

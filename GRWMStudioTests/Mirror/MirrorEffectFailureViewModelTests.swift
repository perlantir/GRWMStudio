@testable import GRWMStudio
import SwiftUI
import XCTest

@MainActor
final class MirrorEffectFailureViewModelTests: XCTestCase {
    func testEffectFailureQueuesFullScreenErrorOnFirstFailure() async {
        let viewModel = MirrorViewModel(usesSimulatorPlaceholder: false)

        await viewModel.selectShade(in: .lips, shade: missingEffectShade)

        XCTAssertEqual(viewModel.pendingFullScreenError, .effectFail)
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testRetryLastSelectionRepeatsFailedShadeLoad() async {
        let viewModel = MirrorViewModel(usesSimulatorPlaceholder: false)

        await viewModel.selectShade(in: .lips, shade: missingEffectShade)
        viewModel.pendingFullScreenError = nil
        await viewModel.retryLastEffect()

        XCTAssertEqual(viewModel.pendingFullScreenError, .effectFail)
        XCTAssertNil(viewModel.selectedShadeID(for: .lips))
    }

    func testRetryLastSelectionWrapperRepeatsFailedShadeLoad() async {
        let viewModel = MirrorViewModel(usesSimulatorPlaceholder: false)

        await viewModel.selectShade(in: .lips, shade: missingEffectShade)
        viewModel.pendingFullScreenError = nil
        await viewModel.retryLastSelection()

        XCTAssertEqual(viewModel.pendingFullScreenError, .effectFail)
    }

    func testDismissEffectFailureBannerOnlyClearsEffectFailure() {
        let viewModel = MirrorViewModel(usesSimulatorPlaceholder: false)

        viewModel.pendingFullScreenError = .license
        viewModel.dismissEffectFailureBanner()
        XCTAssertEqual(viewModel.pendingFullScreenError, .license)

        viewModel.pendingFullScreenError = .effectFail
        viewModel.dismissEffectFailureBanner()
        XCTAssertNil(viewModel.pendingFullScreenError)
    }

    func testRepeatedEffectFailuresEscalateToFailedState() async {
        let viewModel = MirrorViewModel(usesSimulatorPlaceholder: false)

        await viewModel.selectShade(in: .lips, shade: missingEffectShade)
        await viewModel.selectShade(in: .lips, shade: missingEffectShade)
        await viewModel.selectShade(in: .lips, shade: missingEffectShade)

        XCTAssertEqual(viewModel.state, .failed(.effectFail))
        XCTAssertEqual(viewModel.pendingFullScreenError, .effectFail)
    }

    func testPickDifferentLookNotificationCanCoexistWithEffectFailureState() async throws {
        let notificationCenter = NotificationCenter()
        let viewModel = MirrorViewModel(usesSimulatorPlaceholder: false, notificationCenter: notificationCenter)

        await viewModel.selectShade(in: .lips, shade: missingEffectShade)
        notificationCenter.post(name: .pickDifferentLook, object: nil)
        try await Task.sleep(for: .milliseconds(10))

        XCTAssertEqual(viewModel.pendingFullScreenError, .effectFail)
    }

    func testSuccessfulSelectionClearsEffectFailure() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")
        let viewModel = MirrorViewModel(controller: controller)
        let shade = try XCTUnwrap(Shade.skinShades.first(where: { $0.id == "skin.medium" }))

        viewModel.pendingFullScreenError = .effectFail

        await viewModel.selectShade(in: .skin, shade: shade)

        XCTAssertNil(viewModel.pendingFullScreenError)
        XCTAssertEqual(viewModel.selectedShadeID(for: .skin), shade.id)
    }

    private var missingEffectShade: Shade {
        Shade(
            id: "missing.effect",
            name: "Missing",
            swatchColor: DH.pink,
            effectID: "missing-effect",
            parameters: [],
            isPro: false
        )
    }
}

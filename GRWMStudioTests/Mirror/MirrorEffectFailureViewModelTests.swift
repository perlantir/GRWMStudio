@testable import GRWMStudio
import SwiftUI
import XCTest

@MainActor
final class MirrorEffectFailureViewModelTests: XCTestCase {
    func testEffectFailureSetsInlineErrorBeforeThirdFailure() async {
        let viewModel = MirrorViewModel(usesSimulatorPlaceholder: false)

        await viewModel.selectShade(in: .lips, shade: missingEffectShade)

        XCTAssertEqual(viewModel.lastError, .effectFail)
        XCTAssertEqual(viewModel.effectFailureCount, 1)
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testRetryLastSelectionRepeatsFailedShadeLoad() async {
        let viewModel = MirrorViewModel(usesSimulatorPlaceholder: false)

        await viewModel.selectShade(in: .lips, shade: missingEffectShade)
        await viewModel.retryLastSelection()

        XCTAssertEqual(viewModel.lastError, .effectFail)
        XCTAssertEqual(viewModel.effectFailureCount, 2)
    }

    func testThreeFailuresWithinWindowEscalateToFullScreenState() async {
        let viewModel = MirrorViewModel(usesSimulatorPlaceholder: false)

        await viewModel.selectShade(in: .lips, shade: missingEffectShade)
        await viewModel.retryLastSelection()
        await viewModel.retryLastSelection()

        XCTAssertEqual(viewModel.effectFailureCount, 3)
        XCTAssertEqual(viewModel.state, .failed(.effectFail))
    }

    func testFailureWindowRestartsAfterSixtySeconds() async {
        var now = Date(timeIntervalSince1970: 0)
        let viewModel = MirrorViewModel(usesSimulatorPlaceholder: false) {
            now
        }

        await viewModel.selectShade(in: .lips, shade: missingEffectShade)
        now = Date(timeIntervalSince1970: 61)
        await viewModel.retryLastSelection()

        XCTAssertEqual(viewModel.effectFailureCount, 1)
        XCTAssertEqual(viewModel.effectFailureWindowStart, now)
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testSuccessfulSelectionResetsFailureCounterAndDismissesBanner() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")
        let viewModel = MirrorViewModel(controller: controller)
        let shade = try XCTUnwrap(Shade.skinShades.first(where: { $0.id == "skin.medium" }))

        viewModel.effectFailureCount = 2
        viewModel.effectFailureWindowStart = Date(timeIntervalSince1970: 0)
        viewModel.lastError = .effectFail

        await viewModel.selectShade(in: .skin, shade: shade)

        XCTAssertEqual(viewModel.effectFailureCount, 0)
        XCTAssertNil(viewModel.effectFailureWindowStart)
        XCTAssertNil(viewModel.lastError)
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

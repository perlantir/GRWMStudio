@testable import GRWMStudio
import XCTest

@MainActor
final class MirrorResetViewModelTests: XCTestCase {
    func testResetAllClearsSelectionsLoadedEffectsAndOpenTray() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        let lipEffect = try await EffectCatalog.shared.effects(for: .lips)[0]
        let lipShade = try XCTUnwrap(lipEffect.shades.first(where: { $0.id == "bubblegum" }))
        let eyeShade = try XCTUnwrap(Shade.eyeshadowShades.first(where: { $0.id == "eyeshadow.pink" }))
        let look = try await EffectCatalog.shared.effects(for: .looks)[0]

        viewModel.activeCategory = .lips
        await viewModel.selectShade(in: .lips, shade: lipShade)
        await viewModel.selectShade(in: .eyes, shade: eyeShade)
        try await viewModel.selectLook(look)

        await viewModel.resetAll()

        XCTAssertTrue(viewModel.selections.isEmpty)
        XCTAssertTrue(viewModel.eyeSelections.isEmpty)
        XCTAssertNil(viewModel.activeLookName)
        XCTAssertNil(viewModel.activeCategory)
        XCTAssertEqual(viewModel.eyesSubCategory, .shadow)
        XCTAssertTrue(controller.loadedEffects.isEmpty)
        XCTAssertEqual(mock.switches.filter { $0.path == nil }.count, EffectSlot.allCases.count)
    }

    func testResetAllFromFailedStateDoesNotCrashAndDismissesTray() async {
        let viewModel = MirrorViewModel(licenseLoader: { throw DeepARLicense.LoadError.empty })
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.activeCategory = .skin

        await viewModel.resetAll()

        XCTAssertEqual(viewModel.state, .failed(.licenseInvalid))
        XCTAssertNil(viewModel.activeCategory)
        XCTAssertTrue(viewModel.selections.isEmpty)
    }
}

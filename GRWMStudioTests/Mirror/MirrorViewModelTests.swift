@testable import GRWMStudio
import UIKit
import XCTest

@MainActor
final class MirrorViewModelTests: XCTestCase {
    func testStartWithoutCameraPermissionDoesNotRequestSystemPrompt() async {
        let permissions = MirrorPermissionsStub(camera: .notDetermined)
        let environment = AppEnvironment(permissions: permissions)
        let viewModel = MirrorViewModel()

        await viewModel.start(env: environment)

        XCTAssertEqual(viewModel.state, .needsPermission)
        XCTAssertFalse(permissions.requestedCamera)
    }

    func testDeniedCameraQueuesCamDeniedFullScreenError() async {
        let viewModel = MirrorViewModel()

        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .denied)))

        XCTAssertEqual(viewModel.state, .needsPermission)
        XCTAssertEqual(viewModel.pendingFullScreenError, .camDenied)
    }

    func testPauseFromPermissionStateLeavesStateAlone() {
        let viewModel = MirrorViewModel()

        viewModel.pause()

        XCTAssertEqual(viewModel.state, .idle)
    }

    func testMissingLicenseFailsWithLicenseInvalidVariant() async {
        let viewModel = MirrorViewModel(
            licenseLoader: { throw DeepARLicense.LoadError.empty }
        )

        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        XCTAssertEqual(viewModel.state, .failed(.licenseInvalid))
        XCTAssertEqual(viewModel.lastError, .licenseInvalid)
    }

    func testBootstrapTimeoutFailsWithEffectFailVariant() async {
        let mock = MirrorMockDeepARClient(autoInitialize: false, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .milliseconds(20))
        let viewModel = MirrorViewModel(
            controller: controller,
            licenseLoader: { "test-license" },
            usesSimulatorPlaceholder: false
        )

        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        XCTAssertEqual(viewModel.state, .failed(.effectFail))
        XCTAssertEqual(viewModel.lastError, .effectFail)
    }

    func testSelectShadeLoadsEffectAppliesParametersAndTracksSelection() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        let effect = try await EffectCatalog.shared.effects(for: .lips)[0]
        let shade = try XCTUnwrap(effect.shades.first(where: { $0.id == "bubblegum" }))

        await viewModel.selectShade(in: .lips, shade: shade)

        XCTAssertEqual(viewModel.selections[.lips], SlotSelection(effectID: effect.id, shade: shade, isPro: false))
        XCTAssertEqual(controller.loadedEffects[.skin], "baseBeauty")
        XCTAssertEqual(mock.switches.last?.slot, EffectSlot.skin.rawValue)
        XCTAssertFalse(mock.boolParameters.contains { $0.gameObject == "PostprocessLUT" && $0.parameter == "enabled" })
        XCTAssertFalse(mock.floatParameters.contains { $0.gameObject == "PostprocessLUT" && $0.parameter == "lutAmount" })
        XCTAssertTrue(mock.boolParameters.contains { $0.gameObject == "eyeshadow" && $0.parameter == "enabled" && !$0.value })
        XCTAssertTrue(mock.boolParameters.contains { $0.gameObject == "eyeliner" && $0.parameter == "enabled" && !$0.value })
        XCTAssertTrue(mock.boolParameters.contains { $0.gameObject == "eyelashes" && $0.parameter == "enabled" && !$0.value })
        XCTAssertTrue(mock.imageParameters.contains { $0.gameObject == "lips" && $0.parameter == "s_texColor" })
        XCTAssertTrue(mock.boolParameters.contains { $0.gameObject == "lips" && $0.parameter == "enabled" && $0.value })
    }

    func testSelectTypedShadeLoadsEffectAppliesParametersAndTracksSelectionID() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        let shade = try XCTUnwrap(Shade.skinShades.first(where: { $0.id == "skin.medium" }))

        await viewModel.selectShade(in: .skin, shade: shade)

        XCTAssertEqual(viewModel.selectedShadeID(for: .skin), shade.id)
        XCTAssertEqual(viewModel.selections[.skin], SlotSelection(effectID: "baseBeauty", shadeID: shade.id, isPro: false))
        XCTAssertEqual(controller.loadedEffects[.skin], "baseBeauty")
        XCTAssertTrue(mock.vectorParameters.contains { $0.gameObject == "face_makeup" && $0.parameter == "softColor" })
    }

    func testSelectBaseShadeAppliesLUTParameters() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        let shade = try XCTUnwrap(Shade.baseShades.first(where: { $0.id == "base.glow" }))

        await viewModel.selectShade(in: .base, shade: shade)

        XCTAssertEqual(viewModel.selectedShadeID(for: .base), shade.id)
        XCTAssertTrue(mock.vectorParameters.contains { $0.gameObject == "face_makeup" && $0.parameter == "softColor" })
        XCTAssertTrue(mock.floatParameters.contains { $0.gameObject == "face_makeup" && $0.parameter == "softAmount" })
    }

    func testEyeSubCategoriesApplyAdditiveParametersOnSharedSlot() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        let shadow = try XCTUnwrap(Shade.eyeshadowShades.first(where: { $0.id == "eyeshadow.pink" }))
        let liner = try XCTUnwrap(Shade.eyelinerShades.first(where: { $0.id == "eyeliner.classic" }))

        viewModel.eyesSubCategory = .shadow
        await viewModel.selectShade(in: .eyes, shade: shadow)
        viewModel.eyesSubCategory = .liner
        await viewModel.selectShade(in: .eyes, shade: liner)

        XCTAssertEqual(viewModel.selectedEyeShadeID(for: .shadow), shadow.id)
        XCTAssertEqual(viewModel.selectedEyeShadeID(for: .liner), liner.id)
        XCTAssertEqual(viewModel.selections[.eyes], SlotSelection(effectID: "baseBeauty", shadeID: liner.id, isPro: false))
        XCTAssertEqual(mock.switches.filter { $0.slot == EffectSlot.skin.rawValue }.count, 1)
        XCTAssertTrue(mock.vectorParameters.contains { $0.gameObject == "eyeshadow" && $0.parameter == "u_color" })
        XCTAssertTrue(mock.imageParameters.contains { $0.gameObject == "eyeshadow" && $0.parameter == "s_texColor" })
        XCTAssertTrue(mock.boolParameters.contains { $0.gameObject == "eyeshadow" && $0.parameter == "enabled" && $0.value })
        XCTAssertTrue(mock.boolParameters.contains { $0.gameObject == "eyeliner" && $0.parameter == "enabled" && $0.value })
        XCTAssertTrue(mock.imageParameters.contains { $0.gameObject == "eyeliner" && $0.parameter == "s_texColor" })
    }

    func testEyeSubCategoriesDefaultToNoneShadeIDs() {
        let viewModel = MirrorViewModel()

        XCTAssertEqual(viewModel.selectedEyeShadeID(for: .shadow), "eyeshadow.none")
        XCTAssertEqual(viewModel.selectedEyeShadeID(for: .liner), "eyeliner.none")
        XCTAssertEqual(viewModel.selectedEyeShadeID(for: .lashes), "eyelashes.none")
    }

    func testProEyeShadeWithoutEntitlementSetsLicenseError() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(
            controller: controller,
            entitlements: makeEntitlements(false)
        )
        let environment = AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted))
        await viewModel.start(env: environment)

        viewModel.eyesSubCategory = .liner
        let winged = try XCTUnwrap(Shade.eyelinerShades.first(where: { $0.id == "eyeliner.winged" }))

        await viewModel.selectShade(in: .eyes, shade: winged)

        XCTAssertNil(viewModel.selections[.eyes])
        XCTAssertNil(viewModel.eyeSelections[.liner])
        XCTAssertEqual(viewModel.pendingFullScreenError, .license)
        XCTAssertTrue(mock.switches.isEmpty)
    }

    func testProShadeWithoutEntitlementDoesNotLoadEffect() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(
            controller: controller,
            entitlements: makeEntitlements(false)
        )
        let environment = AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted))
        await viewModel.start(env: environment)

        let effect = try await EffectCatalog.shared.effects(for: .lips)[0]
        let shade = try XCTUnwrap(effect.shades.first(where: { $0.id == "vamp" }))

        await viewModel.selectShade(in: .lips, shade: shade)

        XCTAssertNil(viewModel.selections[.lips])
        XCTAssertEqual(viewModel.pendingFullScreenError, .license)
        XCTAssertTrue(mock.switches.isEmpty)
    }

    func testSelectingLookPreservesOtherSlotSelections() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        let lips = try await EffectCatalog.shared.effects(for: .lips)[0]
        let lipShade = try XCTUnwrap(lips.shades.first(where: { $0.id == "bubblegum" }))
        let look = try await EffectCatalog.shared.effects(for: .looks)[0]

        await viewModel.selectShade(in: .lips, shade: lipShade)
        try await viewModel.selectLook(look)

        XCTAssertNotNil(viewModel.selections[.lips])
        XCTAssertEqual(viewModel.selections[.looks], SlotSelection(effectID: look.id, shade: nil, isPro: false))
        XCTAssertEqual(viewModel.activeLookName, look.displayName)
        XCTAssertEqual(mock.switches.last?.slot, EffectSlot.looks.rawValue)
    }

    func testClearSlotUnloadsEffectAndSelection() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        let effect = try await EffectCatalog.shared.effects(for: .lips)[0]
        let shade = try XCTUnwrap(effect.shades.first(where: { $0.id == "bubblegum" }))

        await viewModel.selectShade(in: .lips, shade: shade)
        await viewModel.clear(slot: .lips)

        XCTAssertNil(viewModel.selections[.lips])
        XCTAssertNil(controller.loadedEffects[.lips])
        XCTAssertNil(mock.switches.last?.path)
        XCTAssertTrue(mock.boolParameters.contains { $0.gameObject == "lips" && $0.parameter == "enabled" && !$0.value })
    }

    func testClearEyesDisablesAllSharedEyeNodes() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        let shadow = try XCTUnwrap(Shade.eyeshadowShades.first(where: { $0.id == "eyeshadow.pink" }))
        let liner = try XCTUnwrap(Shade.eyelinerShades.first(where: { $0.id == "eyeliner.classic" }))
        let lashes = try XCTUnwrap(Shade.eyelashShades.first(where: { $0.id == "eyelashes.natural" }))

        viewModel.eyesSubCategory = .shadow
        await viewModel.selectShade(in: .eyes, shade: shadow)
        viewModel.eyesSubCategory = .liner
        await viewModel.selectShade(in: .eyes, shade: liner)
        viewModel.eyesSubCategory = .lashes
        await viewModel.selectShade(in: .eyes, shade: lashes)

        await viewModel.clear(slot: .eyes)

        XCTAssertNil(viewModel.selections[.eyes])
        XCTAssertTrue(viewModel.eyeSelections.isEmpty)
        XCTAssertTrue(mock.boolParameters.contains { $0.gameObject == "eyeshadow" && $0.parameter == "enabled" && !$0.value })
        XCTAssertTrue(mock.boolParameters.contains { $0.gameObject == "eyeliner" && $0.parameter == "enabled" && !$0.value })
        XCTAssertTrue(mock.boolParameters.contains { $0.gameObject == "eyelashes" && $0.parameter == "enabled" && !$0.value })
    }

    func testFaceVisibilityStreamUpdatesFaceDetectedState() async throws {
        let controller = DeepARController()
        let viewModel = MirrorViewModel(controller: controller)

        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))
        controller.updateTrackedFace(true)
        try await waitUntil { viewModel.isFaceDetected }

        XCTAssertTrue(viewModel.isFaceDetected)
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

    private func makeEntitlements(_ isPro: Bool) -> ProEntitlements {
        let suiteName = "app.grwmstudio.tests.mirror.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(isPro, forKey: ProEntitlements.cacheKey)
        return ProEntitlements(defaults: defaults, autoRefresh: false)
    }
}

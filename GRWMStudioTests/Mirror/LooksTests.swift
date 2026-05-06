@testable import GRWMStudio
import XCTest

@MainActor
final class LooksTests: XCTestCase {
    func testLookPresetListMatchesPhaseSpec() {
        XCTAssertEqual(
            Looks.all.map(\.name),
            [
                "Sunday Best",
                "School Day",
                "Birthday Glam",
                "Sleepover",
                "Pop Star",
                "Disco Princess",
                "Garden Party",
                "Time Warp"
            ]
        )
        XCTAssertEqual(Looks.all.map(\.isPro), [false, false, false, false, true, true, true, true])
    }

    func testCurrentManifestAvailabilityForLookCards() {
        XCTAssertTrue(EffectCatalog.shared.containsSync(effectID: "look1"))
        XCTAssertTrue(EffectCatalog.shared.containsSync(effectID: "look2"))
        XCTAssertFalse(EffectCatalog.shared.containsSync(effectID: "look3"))
        XCTAssertFalse(EffectCatalog.shared.containsSync(effectID: "look_pro1"))
    }

    func testSelectLookPresetLoadsAvailableLook() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        let look = try XCTUnwrap(Looks.all.first(where: { $0.id == "look.sunday-best" }))

        await viewModel.selectLook(look)

        XCTAssertEqual(viewModel.selectedLookEffectID, "look1")
        XCTAssertEqual(viewModel.activeLookName, "Sunday Best")
        XCTAssertEqual(mock.switches.last?.slot, EffectSlot.looks.rawValue)
    }

    func testUnavailableLookPresetDoesNothing() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        let look = try XCTUnwrap(Looks.all.first(where: { $0.id == "look.birthday-glam" }))

        await viewModel.selectLook(look)

        XCTAssertNil(viewModel.selectedLookEffectID)
        XCTAssertNil(viewModel.activeLookName)
        XCTAssertTrue(mock.switches.isEmpty)
    }

    func testProLookWithoutEntitlementShowsLicenseError() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller, entitlements: makeEntitlements(false))
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        let look = LookPreset(
            id: "look.test-pro",
            name: "Test Pro",
            thumbnailAsset: "look_legacy01",
            effectID: "look1",
            isPro: true
        )

        await viewModel.selectLook(look)

        XCTAssertNil(viewModel.selectedLookEffectID)
        XCTAssertEqual(viewModel.pendingFullScreenError, .license)
        XCTAssertTrue(mock.switches.isEmpty)
    }

    func testSetTintedTextureRendersAndSkipsUnchangedRepeat() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        let tint = RGBA(0.64, 0.42, 1.00, 0.88)

        try await viewModel.setTintedTexture("lips_matte", tint: tint, on: EffectParameterMap.lipsTexture)
        try await viewModel.setTintedTexture("lips_matte", tint: tint, on: EffectParameterMap.lipsTexture)

        XCTAssertEqual(mock.imageParameters.filter { $0.gameObject == "lips" && $0.parameter == "s_texColor" }.count, 1)
    }

    private func makeEntitlements(_ isPro: Bool) -> ProEntitlements {
        let suiteName = "app.grwmstudio.tests.looks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(isPro, forKey: ProEntitlements.cacheKey)
        return ProEntitlements(defaults: defaults, autoRefresh: false)
    }
}

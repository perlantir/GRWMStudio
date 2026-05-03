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
        XCTAssertEqual(controller.loadedEffects[.lips], effect.id)
        XCTAssertEqual(mock.switches.last?.slot, EffectSlot.lips.rawValue)
        XCTAssertTrue(mock.vectorParameters.contains { $0.gameObject == "lips" && $0.parameter == "u_color" })
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
        XCTAssertTrue(mock.vectorParameters.contains { $0.gameObject == "face_makeup" && $0.parameter == "u_color" })
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
        XCTAssertTrue(mock.boolParameters.contains { $0.gameObject == "PostprocessLUT" && $0.value })
        XCTAssertTrue(mock.imageParameters.contains { $0.gameObject == "PostprocessLUT" && $0.parameter == "s_texLut" })
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
        XCTAssertEqual(mock.switches.filter { $0.slot == EffectSlot.eyes.rawValue }.count, 1)
        XCTAssertTrue(mock.vectorParameters.contains { $0.gameObject == "eyeshadow" && $0.parameter == "u_color" })
        XCTAssertTrue(mock.imageParameters.contains { $0.gameObject == "eyeshadow" && $0.parameter == "s_texMask" })
        XCTAssertTrue(mock.boolParameters.contains { $0.gameObject == "eyeliner" && $0.parameter == "enabled" && $0.value })
        XCTAssertTrue(mock.imageParameters.contains { $0.gameObject == "eyeliner" && $0.parameter == "s_texColor" })
    }

    func testProEyeShadeWithoutEntitlementSetsLicenseError() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        let environment = AppEnvironment(
            permissions: MirrorPermissionsStub(camera: .granted),
            proEntitlement: MirrorProEntitlementStub(hasPro: false)
        )
        await viewModel.start(env: environment)

        viewModel.eyesSubCategory = .liner
        let winged = try XCTUnwrap(Shade.eyelinerShades.first(where: { $0.id == "eyeliner.winged" }))

        await viewModel.selectShade(in: .eyes, shade: winged)

        XCTAssertNil(viewModel.selections[.eyes])
        XCTAssertNil(viewModel.eyeSelections[.liner])
        XCTAssertEqual(viewModel.lastError, .license)
        XCTAssertTrue(mock.switches.isEmpty)
    }

    func testProShadeWithoutEntitlementDoesNotLoadEffect() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        let environment = AppEnvironment(
            permissions: MirrorPermissionsStub(camera: .granted),
            proEntitlement: MirrorProEntitlementStub(hasPro: false)
        )
        await viewModel.start(env: environment)

        let effect = try await EffectCatalog.shared.effects(for: .lips)[0]
        let shade = try XCTUnwrap(effect.shades.first(where: { $0.id == "vamp" }))

        await viewModel.selectShade(in: .lips, shade: shade)

        XCTAssertNil(viewModel.selections[.lips])
        XCTAssertEqual(viewModel.lastError, .license)
        XCTAssertTrue(mock.switches.isEmpty)
    }

    func testSelectingLookClearsOtherSlotSelections() async throws {
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

        XCTAssertNil(viewModel.selections[.lips])
        XCTAssertEqual(viewModel.selections[.looks], SlotSelection(effectID: look.id, shade: nil, isPro: false))
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
}

final class MirrorPermissionsStub: PermissionsService, @unchecked Sendable {
    private let camera: AppPermissionStatus
    private(set) var requestedCamera = false

    init(camera: AppPermissionStatus) {
        self.camera = camera
    }

    func cameraStatus() async -> AppPermissionStatus {
        camera
    }

    @MainActor
    func requestCamera() async -> AppPermissionStatus {
        requestedCamera = true
        return camera
    }

    func micStatus() async -> AppPermissionStatus {
        .granted
    }

    @MainActor
    func requestMic() async -> AppPermissionStatus {
        .granted
    }

    func photosAddStatus() async -> AppPermissionStatus {
        .granted
    }

    @MainActor
    func requestPhotosAdd() async -> AppPermissionStatus {
        .granted
    }

    func notificationsStatus() async -> AppPermissionStatus {
        .denied
    }

    @MainActor
    func requestNotifications() async -> AppPermissionStatus {
        .denied
    }
}

struct MirrorProEntitlementStub: ProEntitlementService {
    let hasPro: Bool
}

@MainActor
final class MirrorMockDeepARClient: DeepARClient {
    struct Switch: Equatable {
        let slot: String
        let path: String?
    }

    struct VectorParameter {
        let gameObject: String
        let parameter: String
        let value: DeepARVectorParameter
    }

    struct BoolParameter {
        let gameObject: String
        let parameter: String
        let value: Bool
    }

    struct ImageParameter {
        let gameObject: String
        let parameter: String
    }

    private let autoInitialize: Bool
    private let autoSwitchEffect: Bool
    private(set) var delegate: DeepARDelegateProxy?
    private(set) var switches: [Switch] = []
    private(set) var vectorParameters: [VectorParameter] = []
    private(set) var boolParameters: [BoolParameter] = []
    private(set) var imageParameters: [ImageParameter] = []

    init(autoInitialize: Bool, autoSwitchEffect: Bool) {
        self.autoInitialize = autoInitialize
        self.autoSwitchEffect = autoSwitchEffect
    }

    func setLicenseKey(_ licenseKey: String) {}

    func setDelegate(_ delegate: DeepARDelegateProxy) {
        self.delegate = delegate
    }

    func createARView(frame: CGRect) -> UIView {
        if autoInitialize {
            Task { @MainActor [weak self] in
                self?.delegate?.didInitialize()
            }
        }
        return UIView(frame: frame)
    }

    func switchEffect(withSlot slot: String, path: String?) {
        switches.append(Switch(slot: slot, path: path))
        if autoSwitchEffect {
            Task { @MainActor [weak self] in
                self?.delegate?.didSwitchEffect(slot)
            }
        }
    }

    func setVectorParameter(
        _ gameObject: String,
        component: String,
        parameter: String,
        value: DeepARVectorParameter
    ) {
        vectorParameters.append(VectorParameter(gameObject: gameObject, parameter: parameter, value: value))
    }

    func setBoolParameter(_ gameObject: String, component: String, parameter: String, value: Bool) {
        boolParameters.append(BoolParameter(gameObject: gameObject, parameter: parameter, value: value))
    }

    func setImageParameter(_ gameObject: String, component: String, parameter: String, image: UIImage) {
        imageParameters.append(ImageParameter(gameObject: gameObject, parameter: parameter))
    }
}

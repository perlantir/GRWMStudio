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

private final class MirrorPermissionsStub: PermissionsService, @unchecked Sendable {
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

private struct MirrorProEntitlementStub: ProEntitlementService {
    let hasPro: Bool
}

@MainActor
private final class MirrorMockDeepARClient: DeepARClient {
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

    private let autoInitialize: Bool
    private let autoSwitchEffect: Bool
    private(set) var delegate: DeepARDelegateProxy?
    private(set) var switches: [Switch] = []
    private(set) var vectorParameters: [VectorParameter] = []
    private(set) var boolParameters: [BoolParameter] = []

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
}

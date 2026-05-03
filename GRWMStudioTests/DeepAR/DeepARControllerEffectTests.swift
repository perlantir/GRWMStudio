@testable import GRWMStudio
import UIKit
import XCTest

@MainActor
final class DeepARControllerEffectTests: XCTestCase {
    func testLoadEffectSwitchesSDKSlotAndTracksLoadedEffect() async throws {
        let mock = EffectMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        let effect = baseBeautyEffect()

        try await controller.bootstrap(licenseKey: "test-license")
        try await controller.loadEffect(effect, slot: .skin)

        XCTAssertEqual(controller.loadedEffects[.skin], effect.id)
        XCTAssertEqual(mock.switches.count, 1)
        XCTAssertEqual(mock.switches[0].slot, EffectSlot.skin.rawValue)
        XCTAssertTrue(mock.switches[0].path?.hasSuffix("/Effects/baseBeauty.deepar") == true)
    }

    func testClearEffectClearsSDKSlotAndLocalTracking() async throws {
        let mock = EffectMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))

        try await controller.bootstrap(licenseKey: "test-license")
        try await controller.loadEffect(baseBeautyEffect(), slot: .skin)
        await controller.clearEffect(slot: .skin)

        XCTAssertNil(controller.loadedEffects[.skin])
        XCTAssertEqual(mock.switches.last?.slot, EffectSlot.skin.rawValue)
        XCTAssertNil(mock.switches.last?.path)
    }

    func testLoadEffectTimeoutKeepsControllerReady() async throws {
        let mock = EffectMockDeepARClient(autoInitialize: true, autoSwitchEffect: false)
        let controller = DeepARController(
            clientFactory: { mock },
            bootstrapTimeout: .seconds(1),
            effectLoadTimeout: .milliseconds(20)
        )

        try await controller.bootstrap(licenseKey: "test-license")

        do {
            try await controller.loadEffect(baseBeautyEffect(), slot: .skin)
            XCTFail("Expected effectLoadFailed timeout")
        } catch DeepARController.SetupError.effectLoadFailed(let slot, let reason) {
            XCTAssertEqual(slot, .skin)
            XCTAssertEqual(reason, "Timeout")
            XCTAssertEqual(controller.state, .ready)
            XCTAssertNil(controller.loadedEffects[.skin])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private func baseBeautyEffect() -> EffectFile {
    EffectFile(
        id: "baseBeauty",
        displayName: "Base Beauty",
        file: "baseBeauty.deepar",
        thumbnail: "thumbnails/baseBeauty.png",
        isPro: false,
        shades: [],
        tag: nil,
        hot: nil
    )
}

@MainActor
private final class EffectMockDeepARClient: DeepARClient {
    struct Switch: Equatable {
        let slot: String
        let path: String?
    }

    private let autoInitialize: Bool
    private let autoSwitchEffect: Bool
    private(set) var delegate: DeepARDelegateProxy?
    private(set) var switches: [Switch] = []

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
}

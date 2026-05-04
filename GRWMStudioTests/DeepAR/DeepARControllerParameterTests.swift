@testable import GRWMStudio
import UIKit
import XCTest

@MainActor
final class DeepARControllerParameterTests: XCTestCase {
    func testSetColorAppliesVectorParameter() async throws {
        let mock = ParameterMockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))

        try await controller.bootstrap(licenseKey: "test-license")
        await controller.setColor(
            UIColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 0.8),
            on: EffectParameterMap.eyeshadowColor
        )

        guard case .vector(let target, let value) = mock.calls.first else {
            XCTFail("Expected vector parameter call")
            return
        }
        XCTAssertEqual(target, ParameterTarget(EffectParameterMap.eyeshadowColor))
        XCTAssertEqual(value.red, 0.25, accuracy: 0.001)
        XCTAssertEqual(value.green, 0.5, accuracy: 0.001)
        XCTAssertEqual(value.blue, 0.75, accuracy: 0.001)
        XCTAssertEqual(value.alpha, 0.8, accuracy: 0.001)
    }

    func testSetTextureAppliesImageParameter() async throws {
        let mock = ParameterMockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        let image = UIGraphicsImageRenderer(size: CGSize(width: 2, height: 3)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 2, height: 3))
        }

        try await controller.bootstrap(licenseKey: "test-license")
        await controller.setTexture(image, on: EffectParameterMap.lipsTexture)

        XCTAssertEqual(mock.calls, [.image(ParameterTarget(EffectParameterMap.lipsTexture), CGSize(width: 2, height: 3))])
    }

    func testSetBlendshapeAppliesFloatParameter() async throws {
        let mock = ParameterMockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))

        try await controller.bootstrap(licenseKey: "test-license")
        await controller.setBlendshape(0.42, on: EffectParameterMap.foundationColor)

        XCTAssertEqual(mock.calls, [.float(ParameterTarget(EffectParameterMap.foundationColor), 0.42)])
    }

    func testSetEnabledAppliesBoolParameter() async throws {
        let mock = ParameterMockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))

        try await controller.bootstrap(licenseKey: "test-license")
        await controller.setEnabled(false, on: EffectParameterMap.lipsEnabled)

        XCTAssertEqual(mock.calls, [.bool(ParameterTarget(EffectParameterMap.lipsEnabled), false)])
    }

    func testParameterCallsNoOpWhenControllerIsNotReady() async {
        let mock = ParameterMockDeepARClient(autoInitialize: false)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))

        await controller.setColor(.red, on: EffectParameterMap.eyeshadowColor)
        await controller.setTexture(UIImage(), on: EffectParameterMap.lipsTexture)
        await controller.setBlendshape(0.3, on: EffectParameterMap.foundationColor)
        await controller.setEnabled(true, on: EffectParameterMap.lipsEnabled)

        XCTAssertTrue(mock.calls.isEmpty)
    }
}

private struct ParameterTarget: Equatable {
    let nodeName: String
    let component: String
    let parameter: String

    init(_ parameter: EffectParameter) {
        nodeName = parameter.nodeName
        component = parameter.component
        self.parameter = parameter.parameter
    }
}

private enum ParameterCall: Equatable {
    case vector(ParameterTarget, DeepARVectorParameter)
    case image(ParameterTarget, CGSize)
    case float(ParameterTarget, Float)
    case bool(ParameterTarget, Bool)
}

@MainActor
private final class ParameterMockDeepARClient: DeepARClient {
    private let autoInitialize: Bool
    private(set) var delegate: DeepARDelegateProxy?
    private(set) var calls: [ParameterCall] = []

    init(autoInitialize: Bool) {
        self.autoInitialize = autoInitialize
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

    func switchEffect(withSlot slot: String, path: String?) {}

    func setVectorParameter(
        _ gameObject: String,
        component: String,
        parameter: String,
        value: DeepARVectorParameter
    ) {
        calls.append(.vector(ParameterTarget(gameObject: gameObject, component: component, parameter: parameter), value))
    }

    func setImageParameter(_ gameObject: String, component: String, parameter: String, image: UIImage) {
        calls.append(
            .image(ParameterTarget(gameObject: gameObject, component: component, parameter: parameter), image.size)
        )
    }

    func setFloatParameter(_ gameObject: String, component: String, parameter: String, value: Float) {
        calls.append(.float(ParameterTarget(gameObject: gameObject, component: component, parameter: parameter), value))
    }

    func setBoolParameter(_ gameObject: String, component: String, parameter: String, value: Bool) {
        calls.append(.bool(ParameterTarget(gameObject: gameObject, component: component, parameter: parameter), value))
    }
}

private extension ParameterTarget {
    init(gameObject: String, component: String, parameter: String) {
        nodeName = gameObject
        self.component = component
        self.parameter = parameter
    }
}

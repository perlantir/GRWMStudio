@testable import GRWMStudio
import UIKit
import XCTest

@MainActor
final class DeepARControllerBootstrapTests: XCTestCase {
    func testBootstrapRejectsMissingLicenseKey() async {
        let mock = MockDeepARClient()
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .milliseconds(100))

        do {
            try await controller.bootstrap(licenseKey: "")
            XCTFail("Expected missingLicenseKey")
        } catch DeepARController.SetupError.missingLicenseKey {
            XCTAssertEqual(controller.state, .failed(reason: "Missing license key"))
            XCTAssertFalse(mock.didSetLicenseKey)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testBootstrapTransitionsToReadyWhenDelegateInitializes() async throws {
        let mock = MockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))

        try await controller.bootstrap(licenseKey: "test-license")

        XCTAssertEqual(controller.state, .ready)
        XCTAssertEqual(mock.licenseKey, "test-license")
        XCTAssertNotNil(mock.delegate)
        XCTAssertEqual(mock.createdFrame, CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertNotNil(controller.arView)
    }

    func testBootstrapTwiceThrowsAlreadyInitialized() async throws {
        let mock = MockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))

        try await controller.bootstrap(licenseKey: "test-license")

        do {
            try await controller.bootstrap(licenseKey: "test-license")
            XCTFail("Expected alreadyInitialized")
        } catch DeepARController.SetupError.alreadyInitialized {
            XCTAssertEqual(controller.state, .ready)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testBootstrapTimeoutFailsState() async {
        let mock = MockDeepARClient(autoInitialize: false)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .milliseconds(20))

        do {
            try await controller.bootstrap(licenseKey: "test-license")
            XCTFail("Expected sdkInitTimeout")
        } catch DeepARController.SetupError.sdkInitTimeout {
            XCTAssertEqual(controller.state, .failed(reason: "SDK init timeout"))
            XCTAssertNil(controller.bootstrapContinuation)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

@MainActor
private final class MockDeepARClient: DeepARClient {
    private let autoInitialize: Bool
    private(set) var didSetLicenseKey = false
    private(set) var licenseKey: String?
    private(set) var delegate: DeepARDelegateProxy?
    private(set) var createdFrame: CGRect?

    init(autoInitialize: Bool = false) {
        self.autoInitialize = autoInitialize
    }

    func setLicenseKey(_ licenseKey: String) {
        didSetLicenseKey = true
        self.licenseKey = licenseKey
    }

    func setDelegate(_ delegate: DeepARDelegateProxy) {
        self.delegate = delegate
    }

    func createARView(frame: CGRect) -> UIView {
        createdFrame = frame
        let view = UIView(frame: frame)
        if autoInitialize {
            Task { @MainActor [weak self] in
                self?.delegate?.didInitialize()
            }
        }
        return view
    }
}

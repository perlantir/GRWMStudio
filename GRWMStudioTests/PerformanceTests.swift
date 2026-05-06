@testable import GRWMStudio
import XCTest

@MainActor
final class PerformanceTests: XCTestCase {
    func testMirrorBootstrapWithMockDeepARCompletesQuickly() {
        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "mirror started")
            Task { @MainActor in
                let viewModel = MirrorViewModel()
                await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))
                XCTAssertEqual(viewModel.state, .running)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1)
        }
    }

    func testShadeApplyWithMockDeepARCompletesQuickly() {
        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "shade applied")
            Task { @MainActor in
                let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
                let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
                try? await controller.bootstrap(licenseKey: "test-license")
                let viewModel = MirrorViewModel(controller: controller)
                await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))
                await viewModel.selectShade(in: .skin, shade: Shade.skinShades[0])
                XCTAssertEqual(viewModel.selectedShadeID(for: .skin), Shade.skinShades[0].id)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1)
        }
    }

    func testMirrorStateMemoryMetric() {
        measure(metrics: [XCTMemoryMetric()]) {
            _ = MirrorViewModel()
        }
    }
}

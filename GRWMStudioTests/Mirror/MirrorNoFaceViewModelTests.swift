@testable import GRWMStudio
import XCTest

@MainActor
final class MirrorNoFaceViewModelTests: XCTestCase {
    override func tearDown() async throws {
        StorageMonitor.resetForTests()
        try await super.tearDown()
    }

    func testSustainedNoFaceQueuesFullScreenErrorAfterDelay() async throws {
        let viewModel = MirrorViewModel(
            usesSimulatorPlaceholder: true,
            noFaceDelay: .milliseconds(20)
        )
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onFaceDetected(true)
        viewModel.onFaceDetected(false)
        try await Task.sleep(for: .milliseconds(60))

        XCTAssertEqual(viewModel.pendingFullScreenError, .noFace)
    }

    func testNoFaceTimerCancelsWhenFaceReturns() async throws {
        let viewModel = MirrorViewModel(
            usesSimulatorPlaceholder: true,
            noFaceDelay: .milliseconds(40)
        )
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onFaceDetected(true)
        viewModel.onFaceDetected(false)
        try await Task.sleep(for: .milliseconds(10))
        viewModel.onFaceDetected(true)
        try await Task.sleep(for: .milliseconds(60))

        XCTAssertTrue(viewModel.isFaceDetected)
        XCTAssertNil(viewModel.pendingFullScreenError)
    }
}

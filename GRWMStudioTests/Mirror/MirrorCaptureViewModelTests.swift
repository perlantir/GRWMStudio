@testable import GRWMStudio
import XCTest

@MainActor
final class MirrorCaptureViewModelTests: XCTestCase {
    func testCaptureModeIsDisabledUntilMirrorIsRunning() {
        let viewModel = MirrorViewModel()

        XCTAssertEqual(viewModel.captureMode, .disabled)
    }

    func testRunningMirrorShowsIdleCaptureMode() async {
        let viewModel = runningViewModel()

        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        XCTAssertEqual(viewModel.captureMode, .idle)
    }

    func testCaptureTapEmitsPhotoEventAndBriefFlashState() async throws {
        let viewModel = runningViewModel()
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onCaptureTap()

        XCTAssertEqual(viewModel.lastCaptureEvent, .photoCapture)
        XCTAssertEqual(viewModel.captureMode, .photoFiring)

        try await Task.sleep(for: .milliseconds(130))
        XCTAssertEqual(viewModel.captureMode, .idle)
    }

    func testLongPressBeginShowsRecordingMode() async {
        let viewModel = runningViewModel()
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onCaptureLongPressBegan()

        XCTAssertEqual(viewModel.captureMode, .videoRecording(secondsElapsed: 0))
    }

    func testLongPressEndEmitsClampedVideoEvent() async {
        let viewModel = runningViewModel()
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onCaptureLongPressBegan()
        viewModel.onCaptureLongPressEnded(duration: 19)

        XCTAssertEqual(viewModel.lastCaptureEvent, .videoCapture(duration: 15))
        XCTAssertEqual(viewModel.captureMode, .idle)
    }

    private func runningViewModel() -> MirrorViewModel {
        MirrorViewModel(
            licenseLoader: { "test-license" },
            usesSimulatorPlaceholder: true
        )
    }
}

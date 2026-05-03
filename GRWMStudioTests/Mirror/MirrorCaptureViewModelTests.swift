@testable import GRWMStudio
import UIKit
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

        await viewModel.capturePhoto()

        XCTAssertEqual(viewModel.lastCaptureEvent, .photoCapture)
        XCTAssertEqual(viewModel.captureMode, .photoFiring)
        XCTAssertTrue(viewModel.flashEnabled)

        try await Task.sleep(for: .milliseconds(130))
        XCTAssertEqual(viewModel.captureMode, .idle)
        XCTAssertFalse(viewModel.flashEnabled)
    }

    func testCapturePhotoSuccessQueuesPreviewAsset() async throws {
        let expectedImage = Self.testImage()
        let viewModel = runningViewModel(photoCapture: { expectedImage })
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        await viewModel.capturePhoto()

        XCTAssertNotNil(viewModel.previewRouteID)
        guard case .photo(let image) = viewModel.pendingPreviewAsset else {
            XCTFail("Expected captured photo asset")
            return
        }
        XCTAssertEqual(image.size, expectedImage.size)
        XCTAssertNil(viewModel.lastError)
    }

    func testCapturePhotoFailureShowsRecordingFailureBannerState() async {
        let viewModel = runningViewModel(
            photoCapture: {
                throw DeepARController.SetupError.captureFailed(reason: "test failure")
            }
        )
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        await viewModel.capturePhoto()

        XCTAssertEqual(viewModel.captureMode, .idle)
        XCTAssertEqual(viewModel.lastError, .recFail)
        XCTAssertNil(viewModel.pendingPreviewAsset)
        XCTAssertNil(viewModel.previewRouteID)

        viewModel.dismissCaptureFailureBanner()
        XCTAssertNil(viewModel.lastError)
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

    private func runningViewModel(photoCapture: (@MainActor () async throws -> UIImage)? = nil) -> MirrorViewModel {
        MirrorViewModel(
            licenseLoader: { "test-license" },
            usesSimulatorPlaceholder: true,
            currentDate: Date.init,
            photoCapture: photoCapture
        )
    }

    private static func testImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 12, height: 16)).image { context in
            UIColor.magenta.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 12, height: 16))
        }
    }
}

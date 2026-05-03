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

        XCTAssertEqual(viewModel.captureMode, .videoCountdown)
    }

    func testCountdownCancelReturnsToIdle() async {
        let viewModel = runningViewModel()
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onCaptureLongPressBegan()
        viewModel.cancelVideoCountdown()

        XCTAssertEqual(viewModel.captureMode, .idle)
    }

    func testCountdownCompleteStartsVideoRecording() async throws {
        let video = MockVideoRecordingCoordinator()
        let viewModel = runningViewModel(videoRecording: video)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onCaptureLongPressBegan()
        await viewModel.videoCountdownComplete()

        XCTAssertTrue(video.didStart)
        XCTAssertEqual(viewModel.captureMode, .videoRecording(secondsElapsed: 0))
        XCTAssertTrue(viewModel.isRecording)
    }

    func testLongPressReleaseFinishesRecordingAndQueuesVideoPreview() async throws {
        let video = MockVideoRecordingCoordinator()
        let viewModel = runningViewModel(videoRecording: video)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onCaptureLongPressBegan()
        await viewModel.videoCountdownComplete()
        _ = await viewModel.endVideoFlow(force: false)

        XCTAssertTrue(video.didFinish)
        XCTAssertEqual(viewModel.captureMode, .idle)
        XCTAssertNotNil(viewModel.previewRouteID)
        guard case .video(let url) = viewModel.pendingPreviewAsset else {
            XCTFail("Expected recorded video asset")
            return
        }
        XCTAssertEqual(url, video.outputURL)
    }

    func testRecordingContinuesPastFormerFreeLimitUntilUserStops() async throws {
        var now = Date()
        let video = MockVideoRecordingCoordinator()
        let viewModel = runningViewModel(currentDate: { now }, videoRecording: video)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onCaptureLongPressBegan()
        await viewModel.videoCountdownComplete()
        now = now.addingTimeInterval(9.2)

        try await Task.sleep(for: .milliseconds(150))

        XCTAssertFalse(video.didFinish)
        if case .videoRecording(let secondsElapsed) = viewModel.captureMode {
            XCTAssertEqual(secondsElapsed, 9.2, accuracy: 0.01)
        } else {
            XCTFail("Expected recording to continue")
        }
        XCTAssertNil(viewModel.recordingProGateRouteID)
        XCTAssertNil(viewModel.pendingRecordingProGateClipURL)

        _ = await viewModel.endVideoFlow(force: true)

        XCTAssertTrue(video.didFinish)
        XCTAssertNotNil(viewModel.previewRouteID)
        guard case .video(let url) = viewModel.pendingPreviewAsset else {
            XCTFail("Expected recorded video asset")
            return
        }
        XCTAssertEqual(url, video.outputURL)
    }

    private func runningViewModel(
        currentDate: @escaping () -> Date = Date.init,
        photoCapture: (@MainActor () async throws -> UIImage)? = nil,
        videoRecording: (any VideoRecordingCoordinating)? = nil
    ) -> MirrorViewModel {
        MirrorViewModel(
            licenseLoader: { "test-license" },
            usesSimulatorPlaceholder: true,
            currentDate: currentDate,
            photoCapture: photoCapture,
            videoRecording: videoRecording
        )
    }

    private static func testImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 12, height: 16)).image { context in
            UIColor.magenta.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 12, height: 16))
        }
    }
}

@MainActor
private final class MockVideoRecordingCoordinator: VideoRecordingCoordinating {
    let outputURL = VideoRecordingCoordinator.makeTemporaryMP4URL()
    private(set) var didStart = false
    private(set) var didFinish = false
    private(set) var currentURL: URL?

    deinit {
        try? FileManager.default.removeItem(at: outputURL)
    }

    func start() async throws -> URL {
        didStart = true
        currentURL = outputURL
        try Data([0, 1, 2, 3]).write(to: outputURL, options: .atomic)
        return outputURL
    }

    func finish() async throws -> URL {
        didFinish = true
        currentURL = nil
        return outputURL
    }

    func reset() {
        currentURL = nil
    }
}

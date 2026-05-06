@testable import GRWMStudio
import UIKit
import XCTest

@MainActor
final class MirrorCaptureViewModelTests: XCTestCase {
    override func tearDown() async throws {
        StorageMonitor.resetForTests()
    }

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

    func testCapturePhotoFailureQueuesRecordingError() async {
        let viewModel = runningViewModel(
            photoCapture: {
                throw DeepARController.SetupError.captureFailed(reason: "test failure")
            }
        )
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        await viewModel.capturePhoto()

        XCTAssertEqual(viewModel.captureMode, .idle)
        XCTAssertEqual(viewModel.pendingFullScreenError, .recFail)
        XCTAssertNil(viewModel.pendingPreviewAsset)
        XCTAssertNil(viewModel.previewRouteID)

        viewModel.dismissCaptureFailureBanner()
        XCTAssertNil(viewModel.pendingFullScreenError)
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

    func testMicDeniedQueuesFullScreenErrorInsteadOfStartingVideoRecording() async {
        let video = MockVideoRecordingCoordinator()
        let viewModel = runningViewModel(videoRecording: video)
        let permissions = MirrorPermissionsStub(camera: .granted, mic: .denied)

        await viewModel.start(env: AppEnvironment(permissions: permissions))
        await viewModel.startVideoRecording(forceNoAudio: false)

        XCTAssertEqual(viewModel.captureMode, .idle)
        XCTAssertEqual(viewModel.pendingFullScreenError, .micDenied)
        XCTAssertFalse(video.didStart)
    }

    func testRecordWithoutAudioNotificationStartsVideoRecordingAfterMicDenied() async throws {
        let notificationCenter = NotificationCenter()
        let video = MockVideoRecordingCoordinator()
        let viewModel = runningViewModel(videoRecording: video, notificationCenter: notificationCenter)
        let permissions = MirrorPermissionsStub(camera: .granted, mic: .denied)

        await viewModel.start(env: AppEnvironment(permissions: permissions))
        await viewModel.startVideoRecording(forceNoAudio: false)
        XCTAssertEqual(viewModel.pendingFullScreenError, .micDenied)

        notificationCenter.post(name: .recordWithoutAudio, object: nil)
        try await Task.sleep(for: .milliseconds(120))

        XCTAssertTrue(video.didStart)
        XCTAssertEqual(video.startWithAudioValues, [false])
        if case .videoRecording(let secondsElapsed) = viewModel.captureMode {
            XCTAssertGreaterThanOrEqual(secondsElapsed, 0)
        } else {
            XCTFail("Expected recording to start without audio")
        }
    }

    func testRetryRecordingNotificationRetriesFailedPhotoCapture() async throws {
        let notificationCenter = NotificationCenter()
        var attempts = 0
        let viewModel = runningViewModel(
            photoCapture: {
                attempts += 1
                if attempts == 1 {
                    throw DeepARController.SetupError.captureFailed(reason: "test failure")
                }
                return Self.testImage()
            },
            notificationCenter: notificationCenter
        )
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        await viewModel.capturePhoto()
        XCTAssertEqual(viewModel.pendingFullScreenError, .recFail)

        notificationCenter.post(name: .retryRecording, object: nil)
        try await Task.sleep(for: .milliseconds(120))

        guard case .photo = viewModel.pendingPreviewAsset else {
            XCTFail("Expected retry to capture a replacement photo")
            return
        }
        XCTAssertEqual(attempts, 2)
    }

    func testLowStorageBlocksVideoRecordingBeforeStart() async {
        StorageMonitor.setAvailableBytesProviderForTests {
            StorageMonitor.recordThreshold - 1
        }

        let video = MockVideoRecordingCoordinator()
        let viewModel = runningViewModel(videoRecording: video)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.selectedCaptureKind = .video
        await viewModel.startVideoRecording(forceNoAudio: false)

        XCTAssertEqual(viewModel.captureMode, .idle)
        XCTAssertEqual(viewModel.pendingFullScreenError, .lowStorage)
        XCTAssertFalse(video.didStart)
    }

    func testFreeRecordingContinuesPastFormerEightSecondCap() async throws {
        var now = Date()
        let video = MockVideoRecordingCoordinator()
        let viewModel = runningViewModel(
            currentDate: { now },
            videoRecording: video,
            entitlements: makeEntitlements(false)
        )
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onCaptureLongPressBegan()
        await viewModel.videoCountdownComplete()
        now = now.addingTimeInterval(8.2)

        try await Task.sleep(for: .milliseconds(150))

        XCTAssertFalse(video.didFinish)
        XCTAssertNil(viewModel.previewRouteID)
        if case .videoRecording(let secondsElapsed) = viewModel.captureMode {
            XCTAssertEqual(secondsElapsed, 8.2, accuracy: 0.01)
        } else {
            XCTFail("Expected recording to continue until the user stops it")
        }
    }

    func testProRecordingContinuesPastFormerFifteenSecondCapUntilUserStops() async throws {
        var now = Date()
        let video = MockVideoRecordingCoordinator()
        let viewModel = runningViewModel(
            currentDate: { now },
            videoRecording: video,
            entitlements: makeEntitlements(true)
        )
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onCaptureLongPressBegan()
        await viewModel.videoCountdownComplete()
        now = now.addingTimeInterval(9.2)

        try await Task.sleep(for: .milliseconds(150))

        XCTAssertFalse(video.didFinish)
        if case .videoRecording(let secondsElapsed) = viewModel.captureMode {
            XCTAssertEqual(secondsElapsed, 9.2, accuracy: 0.01)
        } else {
            XCTFail("Expected recording to continue for Pro")
        }

        now = now.addingTimeInterval(6.0)

        try await Task.sleep(for: .milliseconds(150))

        XCTAssertFalse(video.didFinish)
        if case .videoRecording(let secondsElapsed) = viewModel.captureMode {
            XCTAssertEqual(secondsElapsed, 15.2, accuracy: 0.01)
        } else {
            XCTFail("Expected recording to continue until the user stops it")
        }

        _ = await viewModel.endVideoFlow(force: false)

        XCTAssertTrue(video.didFinish)
        XCTAssertEqual(viewModel.captureMode, .idle)
    }

    private func runningViewModel(
        currentDate: @escaping () -> Date = Date.init,
        photoCapture: (@MainActor () async throws -> UIImage)? = nil,
        videoRecording: (any VideoRecordingCoordinating)? = nil,
        entitlements: ProEntitlements = ProEntitlements(defaults: .standard, autoRefresh: false),
        notificationCenter: NotificationCenter = .default
    ) -> MirrorViewModel {
        MirrorViewModel(
            licenseLoader: { "test-license" },
            usesSimulatorPlaceholder: true,
            currentDate: currentDate,
            photoCapture: photoCapture,
            videoRecording: videoRecording,
            entitlements: entitlements,
            notificationCenter: notificationCenter
        )
    }

    private func makeEntitlements(_ isPro: Bool) -> ProEntitlements {
        let suiteName = "app.grwmstudio.tests.capture.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(isPro, forKey: ProEntitlements.cacheKey)
        return ProEntitlements(defaults: defaults, autoRefresh: false)
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
    private(set) var startWithAudioValues: [Bool] = []

    deinit {
        try? FileManager.default.removeItem(at: outputURL)
    }

    func start(withAudio: Bool) async throws -> URL {
        didStart = true
        startWithAudioValues.append(withAudio)
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

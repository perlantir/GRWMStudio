@testable import GRWMStudio
import UIKit
import XCTest

@MainActor
final class MirrorCaptureEdgeViewModelTests: XCTestCase {
    func testLegacyCaptureTapFiresBriefPhotoState() async throws {
        let viewModel = runningViewModel()
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onCaptureTap()

        XCTAssertEqual(viewModel.lastCaptureEvent, .photoCapture)
        XCTAssertEqual(viewModel.captureMode, .photoFiring)

        try await Task.sleep(for: .milliseconds(130))
        XCTAssertEqual(viewModel.captureMode, .idle)
    }

    func testEndVideoFlowCancelsCountdownWhenNotYetRecording() async {
        let viewModel = runningViewModel()
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onCaptureLongPressBegan()
        let url = await viewModel.endVideoFlow(force: false)

        XCTAssertNil(url)
        XCTAssertEqual(viewModel.captureMode, .idle)
    }

    func testLongPressEndedUsesElapsedDurationAndFinishesRecording() async throws {
        let video = EdgeMockVideoRecordingCoordinator()
        let viewModel = runningViewModel(videoRecording: video)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        viewModel.onCaptureLongPressBegan()
        await viewModel.videoCountdownComplete()
        viewModel.onCaptureLongPressEnded()
        try await waitUntil { video.didFinish }

        XCTAssertEqual(viewModel.captureMode, .idle)
        XCTAssertNotNil(viewModel.previewRouteID)
    }

    func testVideoStartFailureQueuesRecordingErrorAndCleansTemporaryFile() async {
        let video = EdgeMockVideoRecordingCoordinator(failStart: true)
        let viewModel = runningViewModel(videoRecording: video)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        await viewModel.startVideoRecording(forceNoAudio: false)

        XCTAssertEqual(viewModel.captureMode, .idle)
        XCTAssertEqual(viewModel.pendingFullScreenError, .recFail)
        XCTAssertEqual(viewModel.lastCaptureFailureKind, .video)
        XCTAssertFalse(FileManager.default.fileExists(atPath: video.outputURL.path))
    }

    func testVideoFinishFailureQueuesRecordingErrorAndCleansTemporaryFile() async {
        let video = EdgeMockVideoRecordingCoordinator(failFinish: true)
        let viewModel = runningViewModel(videoRecording: video)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        await viewModel.startVideoRecording(forceNoAudio: false)
        let url = await viewModel.endVideoFlow(force: false)

        XCTAssertNil(url)
        XCTAssertEqual(viewModel.captureMode, .idle)
        XCTAssertEqual(viewModel.pendingFullScreenError, .recFail)
        XCTAssertEqual(viewModel.lastCaptureFailureKind, .video)
        XCTAssertFalse(FileManager.default.fileExists(atPath: video.outputURL.path))
    }

    private func runningViewModel(videoRecording: (any VideoRecordingCoordinating)? = nil) -> MirrorViewModel {
        MirrorViewModel(
            licenseLoader: { "test-license" },
            usesSimulatorPlaceholder: true,
            videoRecording: videoRecording,
            entitlements: ProEntitlements(defaults: .standard, autoRefresh: false)
        )
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

@MainActor
private final class EdgeMockVideoRecordingCoordinator: VideoRecordingCoordinating {
    let outputURL = VideoRecordingCoordinator.makeTemporaryMP4URL()
    private let failStart: Bool
    private let failFinish: Bool
    private(set) var didFinish = false
    private(set) var currentURL: URL?

    init(failStart: Bool = false, failFinish: Bool = false) {
        self.failStart = failStart
        self.failFinish = failFinish
    }

    deinit {
        try? FileManager.default.removeItem(at: outputURL)
    }

    func start(withAudio _: Bool) async throws -> URL {
        currentURL = outputURL
        try Data([0, 1, 2, 3]).write(to: outputURL, options: .atomic)
        if failStart {
            throw EdgeMockVideoRecordingError.start
        }
        return outputURL
    }

    func finish() async throws -> URL {
        didFinish = true
        if failFinish {
            throw EdgeMockVideoRecordingError.finish
        }
        currentURL = nil
        return outputURL
    }

    func reset() {
        currentURL = nil
    }
}

private enum EdgeMockVideoRecordingError: Error {
    case start
    case finish
}

@testable import GRWMStudio
import UIKit
import XCTest

@MainActor
final class MirrorCaptureTapViewModelTests: XCTestCase {
    func testCaptureButtonTappedRoutesPhotoModeToPhotoCapture() async {
        let viewModel = runningViewModel(photoCapture: { Self.testImage() })
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))
        viewModel.selectedCaptureKind = .photo

        await viewModel.captureButtonTapped()

        XCTAssertNotNil(viewModel.previewRouteID)
        XCTAssertEqual(viewModel.lastCaptureEvent, .photoCapture)
    }

    func testCaptureButtonTappedStartsAndStopsVideoMode() async {
        let video = TapMockVideoRecordingCoordinator()
        let viewModel = runningViewModel(videoRecording: video)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))
        viewModel.selectedCaptureKind = .video

        await viewModel.captureButtonTapped()

        XCTAssertTrue(video.didStart)
        XCTAssertTrue(viewModel.isAwaitingVideoRelease)

        await viewModel.captureButtonTapped()

        XCTAssertTrue(video.didFinish)
        XCTAssertNotNil(viewModel.previewRouteID)
        XCTAssertEqual(viewModel.captureMode, .idle)
    }

    func testSelectedCaptureShadeIDsCombinesSlotsAndEyeSubSelections() {
        let viewModel = runningViewModel()
        viewModel.selections[.lips] = SlotSelection(effectID: "lips", shadeID: "lip.classic-red", isPro: false)
        viewModel.eyeSelections[.shadow] = "eyeshadow.pink"
        viewModel.eyeSelections[.liner] = "eyeliner.classic"

        XCTAssertEqual(viewModel.selectedCaptureShadeIDs, ["eyeliner.classic", "eyeshadow.pink", "lip.classic-red"])
    }

    private func runningViewModel(
        photoCapture: (@MainActor () async throws -> UIImage)? = nil,
        videoRecording: (any VideoRecordingCoordinating)? = nil
    ) -> MirrorViewModel {
        MirrorViewModel(
            licenseLoader: { "test-license" },
            usesSimulatorPlaceholder: true,
            photoCapture: photoCapture,
            videoRecording: videoRecording,
            entitlements: ProEntitlements(defaults: .standard, autoRefresh: false)
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
private final class TapMockVideoRecordingCoordinator: VideoRecordingCoordinating {
    let outputURL = VideoRecordingCoordinator.makeTemporaryMP4URL()
    private(set) var didStart = false
    private(set) var didFinish = false
    private(set) var currentURL: URL?

    deinit {
        try? FileManager.default.removeItem(at: outputURL)
    }

    func start(withAudio: Bool) async throws -> URL {
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

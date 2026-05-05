@testable import GRWMStudio
import UIKit
import XCTest

@MainActor
final class DeepARControllerRecordingTests: XCTestCase {
    func testCapturePhotoWritesDelegateScreenshot() async throws {
        let mock = RecordingMockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))

        try await controller.bootstrap(licenseKey: "test-license")
        let url = try await controller.capturePhoto()
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertEqual(url.pathExtension, "jpg")
        XCTAssertTrue(mock.didTakeScreenshot)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testStartVideoRecordingCallsSDKAndSetsState() async throws {
        let mock = RecordingMockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))

        try await controller.bootstrap(licenseKey: "test-license")
        try await controller.startVideoRecording(maxDuration: 10)

        XCTAssertTrue(controller.isRecordingVideo)
        XCTAssertEqual(mock.videoStartSize?.width, 720)
        XCTAssertEqual(mock.videoStartSize?.height, 960)
        XCTAssertTrue(mock.videoOutputName?.hasPrefix("rec_sdk_") == true)
        XCTAssertEqual(mock.videoOutputPath, FileManager.default.temporaryDirectory.path)

        controller.failCaptureAndRecording(reason: "test cleanup")
    }

    func testStopVideoRecordingMovesDelegateVideo() async throws {
        let mock = RecordingMockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))

        try await controller.bootstrap(licenseKey: "test-license")
        try await controller.startVideoRecording(maxDuration: 10)
        let url = try await controller.stopVideoRecording()
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertFalse(controller.isRecordingVideo)
        XCTAssertTrue(mock.didFinishVideoRecording)
        XCTAssertEqual(url.pathExtension, "mp4")
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testAutoStopFinishesRecordingAtMaxDuration() async throws {
        let mock = RecordingMockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))

        try await controller.bootstrap(licenseKey: "test-license")
        try await controller.startVideoRecording(maxDuration: 0.15)
        try await Task.sleep(for: .milliseconds(450))

        XCTAssertFalse(controller.isRecordingVideo)
        XCTAssertTrue(mock.didFinishVideoRecording)
    }

    func testRecordingServiceFacadeDelegatesToController() async throws {
        let mock = RecordingMockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        let service = RecordingService(controller: controller)

        try await controller.bootstrap(licenseKey: "test-license")
        try await service.startVideo(maxDuration: 10)
        let url = try await service.stopVideo()
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertTrue(mock.didStartVideoRecording)
        XCTAssertTrue(mock.didFinishVideoRecording)
    }

    func testRecordingServiceStartAndFinishVideoRecordingReturnsTemporaryMP4() async throws {
        let mock = RecordingMockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        let service = RecordingService(controller: controller)

        try await controller.bootstrap(licenseKey: "test-license")
        let reservedURL = try await service.startVideoRecording(includeAudio: true)
        let finishedURL = try await service.finishVideoRecording()
        defer { try? FileManager.default.removeItem(at: finishedURL) }

        XCTAssertEqual(reservedURL.pathExtension, "mov")
        XCTAssertEqual(finishedURL.pathExtension, "mp4")
        XCTAssertTrue(finishedURL.path.hasPrefix(FileManager.default.temporaryDirectory.path))
        XCTAssertTrue(mock.didStartVideoRecording)
        XCTAssertTrue(mock.didFinishVideoRecording)
        XCTAssertTrue(controller.cameraIncludesAudio)
    }

    func testRecordingServiceTakeScreenshotReturnsDelegateImage() async throws {
        let mock = RecordingMockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        let service = RecordingService(controller: controller)

        try await controller.bootstrap(licenseKey: "test-license")
        let image = try await service.takeScreenshot()

        XCTAssertTrue(mock.didTakeScreenshot)
        XCTAssertEqual(image.size.width, 8)
        XCTAssertEqual(image.size.height, 8)
    }
}

@MainActor
private final class RecordingMockDeepARClient: DeepARClient {
    struct VideoSize: Equatable {
        let width: Int32
        let height: Int32
    }

    private let autoInitialize: Bool
    private(set) var delegate: DeepARDelegateProxy?
    private(set) var didTakeScreenshot = false
    private(set) var didStartVideoRecording = false
    private(set) var didFinishVideoRecording = false
    private(set) var videoStartSize: VideoSize?
    private(set) var videoOutputPath: String?
    private(set) var videoOutputName: String?

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

    func takeScreenshot() {
        didTakeScreenshot = true
        delegate?.didTakeScreenshot(testImage())
    }

    func startVideoRecording(outputWidth: Int32, outputHeight: Int32) {
        didStartVideoRecording = true
        videoStartSize = VideoSize(width: outputWidth, height: outputHeight)
        delegate?.didStartVideoRecording()
    }

    func setVideoRecordingOutputPath(_ path: String) {
        videoOutputPath = path
    }

    func setVideoRecordingOutputName(_ name: String) {
        videoOutputName = name
    }

    func finishVideoRecording() {
        didFinishVideoRecording = true
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).mp4")
        try? Data([0, 1, 2, 3]).write(to: url)
        delegate?.didFinishVideoRecording(url.path)
    }

    private func testImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8)).image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 8, height: 8))
        }
    }
}

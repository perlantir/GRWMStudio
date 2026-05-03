import Foundation
import UIKit

/// Thin facade over DeepAR photo and video capture.
@MainActor
public final class RecordingService {
    private let controller: DeepARController
    private var tickTask: Task<Void, Never>?
    /// Temporary URL reserved for the active video recording session.
    public private(set) var currentVideoURL: URL?

    /// Creates a recording service for one DeepAR controller.
    public init(controller: DeepARController) {
        self.controller = controller
    }

    deinit {
        tickTask?.cancel()
    }

    /// Takes a photo and returns the saved local file URL.
    public func takePhoto() async throws -> URL {
        try await controller.capturePhoto()
    }

    /// Takes a photo and returns the in-memory screenshot image.
    public func takeScreenshot() async throws -> UIImage {
        try await controller.captureScreenshotImage()
    }

    /// Starts video recording and optionally reports duration ticks.
    public func startVideo(
        maxDuration: TimeInterval,
        onTick: (@MainActor @Sendable (TimeInterval) -> Void)? = nil
    ) async throws {
        try await controller.startVideoRecording(maxDuration: maxDuration)
        startTickForwarder(onTick: onTick)
    }

    /// Starts video recording and returns the reserved temporary output URL.
    public func startVideoRecording() async throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("rec_\(UUID().uuidString).mov")
        currentVideoURL = url

        try await controller.startVideoRecording(outputURL: url)
        return url
    }

    /// Finishes video recording and returns the saved temporary MP4 URL.
    public func finishVideoRecording() async throws -> URL {
        tickTask?.cancel()
        tickTask = nil

        let finishedURL = try await controller.stopVideoRecording()
        currentVideoURL = nil
        return finishedURL
    }

    /// Stops video recording and returns the saved local file URL.
    public func stopVideo() async throws -> URL {
        try await finishVideoRecording()
    }

    private func startTickForwarder(onTick: (@MainActor @Sendable (TimeInterval) -> Void)?) {
        tickTask?.cancel()
        guard let onTick else {
            return
        }

        tickTask = Task { @MainActor [weak self] in
            while let self, self.controller.isRecordingVideo, !Task.isCancelled {
                onTick(self.controller.recordingDuration)
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }
}

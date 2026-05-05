import Foundation
import OSLog
import UIKit

extension DeepARController {
    /// Captures the current DeepAR preview to a local JPEG file.
    public func capturePhoto() async throws -> URL {
        guard recordingClient(method: "capturePhoto") != nil else {
            throw SetupError.captureFailed(reason: "DeepAR not ready")
        }

        do {
            return try await withTimeout(.seconds(4)) { [weak self] in
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
                    guard let self else {
                        continuation.resume(throwing: SetupError.captureFailed(reason: "Controller deallocated"))
                        return
                    }

                    guard let client = self._client else {
                        continuation.resume(throwing: SetupError.captureFailed(reason: "Missing DeepAR instance"))
                        return
                    }

                    self.photoContinuation = continuation
                    client.takeScreenshot()
                }
            }
        } catch is TimeoutError {
            photoContinuation?.resume(throwing: SetupError.captureFailed(reason: "Timeout"))
            photoContinuation = nil
            throw SetupError.captureFailed(reason: "Timeout")
        } catch {
            photoContinuation = nil
            throw error
        }
    }

    /// Captures the current DeepAR preview and returns the raw screenshot image.
    public func captureScreenshotImage() async throws -> UIImage {
        guard recordingClient(method: "captureScreenshotImage") != nil else {
            throw SetupError.captureFailed(reason: "DeepAR not ready")
        }

        do {
            return try await withTimeout(.seconds(4)) { [weak self] in
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UIImage, Error>) in
                    guard let self else {
                        continuation.resume(throwing: SetupError.captureFailed(reason: "Controller deallocated"))
                        return
                    }

                    guard let client = self._client else {
                        continuation.resume(throwing: SetupError.captureFailed(reason: "Missing DeepAR instance"))
                        return
                    }

                    self.screenshotContinuation = continuation
                    client.takeScreenshot()
                }
            }
        } catch is TimeoutError {
            screenshotContinuation?.resume(throwing: SetupError.captureFailed(reason: "Timeout"))
            screenshotContinuation = nil
            throw SetupError.captureFailed(reason: "Timeout")
        } catch {
            screenshotContinuation = nil
            throw error
        }
    }

    /// Starts video recording for the current DeepAR preview.
    public func startVideoRecording(maxDuration: TimeInterval) async throws {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("rec_sdk_\(UUID().uuidString).mov")
        try await startVideoRecording(outputURL: outputURL, maxDuration: maxDuration)
    }

    /// Starts video recording for the current DeepAR preview at a specific SDK output location.
    public func startVideoRecording(outputURL: URL, maxDuration: TimeInterval? = nil) async throws {
        guard let client = recordingClient(method: "startVideoRecording") else {
            throw SetupError.recordingFailed(reason: "DeepAR not ready")
        }
        guard !isRecordingVideo else {
            return
        }

        client.setVideoRecordingOutputPath(outputURL.deletingLastPathComponent().path)
        client.setVideoRecordingOutputName(outputURL.deletingPathExtension().lastPathComponent)
        client.startVideoRecording(
            outputWidth: Int32(Self.recordingOutputSize.width),
            outputHeight: Int32(Self.recordingOutputSize.height)
        )
        isRecordingVideo = true
        recordingDuration = 0
        Logger.deepAR.info("Started video recording")

        if let maxDuration {
            startRecordingProgressTimer(maxDuration: maxDuration)
        }
    }

    /// Stops video recording and returns the saved local file URL.
    public func stopVideoRecording() async throws -> URL {
        guard isRecordingVideo, _client != nil else {
            throw SetupError.recordingFailed(reason: "Not recording")
        }

        do {
            return try await withTimeout(.seconds(6)) { [weak self] in
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
                    guard let self else {
                        continuation.resume(throwing: SetupError.recordingFailed(reason: "Controller deallocated"))
                        return
                    }

                    guard let client = self._client else {
                        continuation.resume(throwing: SetupError.recordingFailed(reason: "Missing DeepAR instance"))
                        return
                    }

                    self.videoContinuation = continuation
                    client.finishVideoRecording()
                }
            }
        } catch is TimeoutError {
            failVideoContinuation(reason: "Timeout")
            throw SetupError.recordingFailed(reason: "Timeout")
        } catch {
            failVideoContinuation(reason: error.localizedDescription)
            throw error
        }
    }

    func completePhotoCapture(with screenshot: UIImage) {
        if let screenshotContinuation {
            screenshotContinuation.resume(returning: screenshot)
            self.screenshotContinuation = nil
            return
        }

        do {
            let url = try CaptureService.writeImage(screenshot)
            photoContinuation?.resume(returning: url)
        } catch {
            photoContinuation?.resume(throwing: SetupError.captureFailed(reason: error.localizedDescription))
        }
        photoContinuation = nil
    }

    func completeVideoRecording(sourcePath: String) async {
        isRecordingVideo = false
        recordingProgressTask?.cancel()
        recordingProgressTask = nil

        do {
            let url = try CaptureService.moveVideoToTemporaryVideo(from: sourcePath)
            videoContinuation?.resume(returning: url)
        } catch {
            videoContinuation?.resume(throwing: SetupError.recordingFailed(reason: error.localizedDescription))
        }
        videoContinuation = nil
    }

    func failCaptureAndRecording(reason: String) {
        isRecordingVideo = false
        recordingProgressTask?.cancel()
        recordingProgressTask = nil
        recordingDuration = 0

        videoContinuation?.resume(throwing: SetupError.recordingFailed(reason: reason))
        videoContinuation = nil
        photoContinuation?.resume(throwing: SetupError.captureFailed(reason: reason))
        photoContinuation = nil
        screenshotContinuation?.resume(throwing: SetupError.captureFailed(reason: reason))
        screenshotContinuation = nil
    }

    private func recordingClient(method: String) -> (any DeepARClient)? {
        guard state == .ready, let client = _client else {
            Logger.deepAR.info("\(method) skipped (not ready)")
            return nil
        }
        return client
    }

    private func startRecordingProgressTimer(maxDuration: TimeInterval) {
        recordingProgressTask?.cancel()
        let startedAt = Date()

        recordingProgressTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                guard let self else {
                    return
                }

                let elapsed = Date().timeIntervalSince(startedAt)
                self.recordingDuration = elapsed

                guard self.isRecordingVideo else {
                    return
                }

                if elapsed >= maxDuration {
                    _ = try? await self.stopVideoRecording()
                    return
                }
            }
        }
    }

    private func failVideoContinuation(reason: String) {
        isRecordingVideo = false
        recordingProgressTask?.cancel()
        recordingProgressTask = nil
        videoContinuation?.resume(throwing: SetupError.recordingFailed(reason: reason))
        videoContinuation = nil
    }

    private static var recordingOutputSize: CGSize {
        CGSize(width: 720, height: 960)
    }
}

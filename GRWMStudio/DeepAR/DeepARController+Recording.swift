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
                    Task { @MainActor in
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

    /// Starts video recording for the current DeepAR preview.
    public func startVideoRecording(maxDuration: TimeInterval) async throws {
        guard let client = recordingClient(method: "startVideoRecording") else {
            throw SetupError.recordingFailed(reason: "DeepAR not ready")
        }
        guard !isRecordingVideo else {
            return
        }

        client.startVideoRecording(outputWidth: 720, outputHeight: 1_280)
        isRecordingVideo = true
        recordingDuration = 0
        Logger.deepAR.info("Started video recording (max: \(maxDuration)s)")
        startRecordingProgressTimer(maxDuration: maxDuration)
    }

    /// Stops video recording and returns the saved local file URL.
    public func stopVideoRecording() async throws -> URL {
        guard isRecordingVideo, _client != nil else {
            throw SetupError.recordingFailed(reason: "Not recording")
        }

        do {
            return try await withTimeout(.seconds(6)) { [weak self] in
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
                    Task { @MainActor in
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
            let url = try CaptureService.moveVideo(from: sourcePath)
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
}

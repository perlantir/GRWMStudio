import OSLog
import UIKit

extension MirrorViewModel {
    var captureMode: CaptureMode {
        guard state == .running else {
            return .disabled
        }

        return activeCaptureMode
    }

    func onCaptureTap() {
        guard state == .running else {
            return
        }

        captureTickTask?.cancel()
        capturePressStartedAt = nil
        activeCaptureMode = .photoFiring
        lastCaptureEvent = .photoCapture
        DHHaptics.tapMedium()
        Logger.mirror.info("Capture event: photoCapture")

        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(100))
            guard self?.activeCaptureMode == .photoFiring else {
                return
            }
            self?.activeCaptureMode = .idle
        }
    }

    func capturePhoto() async {
        guard state == .running else {
            return
        }

        captureTickTask?.cancel()
        captureTickTask = nil
        capturePressStartedAt = nil
        lastError = nil
        activeCaptureMode = .photoFiring
        lastCaptureEvent = .photoCapture
        flashEnabled = true
        DHHaptics.heavy()
        Sounds.shutter.play()
        Logger.mirror.info("Capture event: photoCapture")

        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(100))
            self?.flashEnabled = false
            guard self?.activeCaptureMode == .photoFiring else {
                return
            }
            self?.activeCaptureMode = .idle
        }

        do {
            let image: UIImage
            if ProcessInfo.processInfo.shouldForcePhotoCaptureFailure {
                throw DeepARController.SetupError.captureFailed(reason: "Debug forced photo capture failure")
            } else if let photoCapture {
                image = try await photoCapture()
            } else {
                image = try await PhotoCaptureCoordinator(controller: controller)
                    .capturePhoto(allowSimulatorPlaceholder: shouldSkipControllerCallsForSimulator)
            }

            pendingPreviewAsset = .photo(image)
            previewRouteID = UUID()
        } catch {
            activeCaptureMode = .idle
            lastError = .recFail
            Logger.mirror.error("Photo capture failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func onCaptureLongPressBegan() {
        guard state == .running else {
            return
        }

        capturePressStartedAt = currentDate()
        activeCaptureMode = .videoRecording(secondsElapsed: 0)
        DHHaptics.tapMedium()
        Logger.mirror.info("Capture event: videoCapture began")
        startCaptureTickTask()
    }

    func dismissCaptureFailureBanner() {
        guard lastError == .recFail else {
            return
        }

        lastError = nil
    }

    func onCaptureLongPressEnded() {
        let elapsed = capturePressStartedAt.map { currentDate().timeIntervalSince($0) } ?? 0
        onCaptureLongPressEnded(duration: elapsed)
    }

    func onCaptureLongPressEnded(duration: Double) {
        guard state == .running else {
            return
        }

        let clampedDuration = min(max(0, duration), CapturePressClassifier.maxVideoDuration)
        captureTickTask?.cancel()
        captureTickTask = nil
        capturePressStartedAt = nil
        activeCaptureMode = .idle
        lastCaptureEvent = .videoCapture(duration: clampedDuration)
        Logger.mirror.info("Capture event: videoCapture duration=\(clampedDuration, privacy: .public)")
    }

    private func startCaptureTickTask() {
        captureTickTask?.cancel()
        captureTickTask = Task { @MainActor [weak self] in
            while let self, !Task.isCancelled {
                guard let startedAt = self.capturePressStartedAt else {
                    return
                }

                let elapsed = min(
                    self.currentDate().timeIntervalSince(startedAt),
                    CapturePressClassifier.maxVideoDuration
                )
                self.activeCaptureMode = .videoRecording(secondsElapsed: elapsed)
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }
}

private extension ProcessInfo {
    var shouldForcePhotoCaptureFailure: Bool {
        #if DEBUG
        arguments.contains("-GRWMDebugPhotoCaptureFail")
        #else
        false
        #endif
    }
}

import OSLog
import UIKit

extension MirrorViewModel {
    var captureMode: CaptureMode {
        guard state == .running else {
            return .disabled
        }

        return activeCaptureMode
    }

    func captureButtonTapped() async {
        guard state == .running else {
            return
        }

        switch selectedCaptureKind {
        case .photo:
            await capturePhoto()
        case .video:
            await toggleVideoRecording()
        }
    }

    var isAwaitingVideoRelease: Bool {
        switch activeCaptureMode {
        case .videoCountdown, .videoRecording:
            true
        default:
            false
        }
    }

    var selectedCaptureShadeIDs: [String] {
        let slotShadeIDs = selections.values.compactMap(\.shadeID)
        let eyeShadeIDs = Array(eyeSelections.values)
        return Array(Set(slotShadeIDs + eyeShadeIDs)).sorted()
    }

    func onCaptureTap() {
        guard state == .running else {
            return
        }

        captureTickTask?.cancel()
        capturePressStartedAt = nil
        activeCaptureMode = .photoFiring
        lastCaptureEvent = .photoCapture
        DHHaptics.shared.fire(.tap)
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
        DHHaptics.shared.fire(.shutter)
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

            lastCaptureFailureKind = nil
            pendingPreviewAsset = .photo(image)
            previewRouteID = UUID()
        } catch {
            activeCaptureMode = .idle
            lastCaptureFailureKind = .photo
            pendingFullScreenError = .recFail
            Logger.mirror.error("Photo capture failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func onCaptureLongPressBegan() {
        guard state == .running else {
            return
        }

        guard activeCaptureMode == .idle else {
            return
        }

        captureTickTask?.cancel()
        captureTickTask = nil
        capturePressStartedAt = currentDate()
        activeCaptureMode = .videoCountdown
        lastError = nil
        DHHaptics.shared.fire(.pop)
        Logger.mirror.info("Capture event: videoCountdown began")
    }

    func dismissCaptureFailureBanner() {
        guard pendingFullScreenError == .recFail else {
            return
        }

        pendingFullScreenError = nil
    }

    func onCaptureLongPressEnded() {
        let elapsed = capturePressStartedAt.map { currentDate().timeIntervalSince($0) } ?? 0
        onCaptureLongPressEnded(duration: elapsed)
    }

    func onCaptureLongPressEnded(duration: Double) {
        guard state == .running else {
            return
        }

        Task { @MainActor [weak self] in
            await self?.endVideoFlow(force: false)
        }
    }

    func cancelVideoCountdown() {
        guard activeCaptureMode == .videoCountdown else {
            return
        }

        capturePressStartedAt = nil
        activeCaptureMode = .idle
        Logger.mirror.info("Capture event: videoCountdown canceled")
    }

    func videoCountdownComplete() async {
        guard state == .running, activeCaptureMode == .videoCountdown else {
            return
        }

        await startVideoRecording(forceNoAudio: false)
    }

    private func toggleVideoRecording() async {
        switch activeCaptureMode {
        case .idle:
            await startVideoRecordingFromTap()
        case .videoRecording:
            await endVideoFlow(force: false)
        case .videoCountdown:
            cancelVideoCountdown()
        case .photoFiring, .disabled:
            break
        }
    }

    private func startVideoRecordingFromTap() async {
        guard activeCaptureMode == .idle else {
            return
        }

        captureTickTask?.cancel()
        captureTickTask = nil
        capturePressStartedAt = currentDate()
        lastError = nil
        DHHaptics.shared.fire(.shutter)
        Logger.mirror.info("Capture event: videoRecording start tapped")

        await startVideoRecording(forceNoAudio: false)
    }

    func startVideoRecording(forceNoAudio: Bool) async {
        guard state == .running else {
            return
        }

        guard StorageMonitor.canRecord else {
            cleanupFailedRecording()
            capturePressStartedAt = nil
            recordingStart = nil
            activeCaptureMode = .idle
            pendingFullScreenError = .lowStorage
            Logger.mirror.error("Video recording blocked by low storage")
            return
        }

        let wantsAudio = !forceNoAudio
        let shouldRecordAudio = wantsAudio && !shouldSkipControllerCallsForSimulator

        if wantsAudio {
            let micStatus = await env?.permissions.micStatus() ?? .granted
            if micStatus == .denied || micStatus == .restricted {
                capturePressStartedAt = nil
                recordingStart = nil
                activeCaptureMode = .idle
                pendingFullScreenError = .micDenied
                Logger.mirror.info("Capture event: micDenied surfaced before recording")
                return
            }
        }

        do {
            _ = try await videoRecording.start(withAudio: shouldRecordAudio)
            recordingStart = currentDate()
            activeCaptureMode = .videoRecording(secondsElapsed: 0)
            lastCaptureFailureKind = nil
            lastCaptureEvent = nil
            Logger.mirror.info("Capture event: videoRecording started")
            startRecordingTimer()
        } catch {
            cleanupFailedRecording()
            capturePressStartedAt = nil
            recordingStart = nil
            activeCaptureMode = .idle
            lastCaptureFailureKind = .video
            pendingFullScreenError = .recFail
            Logger.mirror.error("Video recording failed to start: \(error.localizedDescription, privacy: .public)")
        }
    }

    @discardableResult
    func endVideoFlow(force _: Bool) async -> URL? {
        recordingTimer?.invalidate()
        recordingTimer = nil

        guard case .videoRecording = activeCaptureMode else {
            if activeCaptureMode == .videoCountdown {
                cancelVideoCountdown()
            }
            return nil
        }

        let elapsed = currentRecordingElapsed
        capturePressStartedAt = nil
        recordingStart = nil

        do {
            let url = try await videoRecording.finish()
            activeCaptureMode = .idle
            lastCaptureFailureKind = nil
            lastCaptureEvent = .videoCapture(duration: elapsed)
            pendingPreviewAsset = .video(url)
            previewRouteID = UUID()

            Logger.mirror.info("Capture event: videoCapture duration=\(elapsed, privacy: .public)")
            return url
        } catch {
            cleanupFailedRecording()
            activeCaptureMode = .idle
            lastCaptureFailureKind = .video
            pendingFullScreenError = .recFail
            Logger.mirror.error("Video recording failed to finish: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    private func startRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.tickRecording()
            }
        }
    }

    private func tickRecording() async {
        guard recordingStart != nil else {
            return
        }

        let elapsed = currentRecordingElapsed
        activeCaptureMode = .videoRecording(secondsElapsed: elapsed)

        guard elapsed >= recordingCapDuration else {
            return
        }

        _ = await endVideoFlow(force: true)
    }

    private var currentRecordingElapsed: TimeInterval {
        guard let recordingStart else {
            return 0
        }

        return max(0, currentDate().timeIntervalSince(recordingStart))
    }

    private var recordingCapDuration: TimeInterval {
        entitlements.isPro ? 15.0 : 8.0
    }

    private func cleanupFailedRecording() {
        if let url = videoRecording.currentURL {
            try? FileManager.default.removeItem(at: url)
        }
        videoRecording.reset()
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

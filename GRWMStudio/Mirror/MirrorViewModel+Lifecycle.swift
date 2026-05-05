import Foundation
import OSLog
import SwiftUI

extension MirrorViewModel {
    func start(env: AppEnvironment) async {
        guard state != .starting && state != .running else {
            return
        }

        self.env = env
        observeErrorActions()
        state = .starting

        if DebugRuntimeFlags.contains("-GRWMDebugSlowMirrorStart") {
            try? await Task.sleep(for: .seconds(2))
        }

        guard await prepareCameraPermission(using: env) else {
            return
        }

        observeFaceVisibility()

        let licenseKey: String
        do {
            licenseKey = try licenseLoader()
        } catch {
            state = .failed(.licenseInvalid)
            lastError = .licenseInvalid
            Logger.mirror.error("DeepAR license missing or empty")
            return
        }

        if usesSimulatorPlaceholder {
            state = .running
            applyDebugCaptureModeIfNeeded()
            markFaceVisibleForDebugAppShellIfNeeded()
            Logger.deepAR.info("Mirror using simulator DeepAR placeholder")
            return
        }

        do {
            if controller.state == .uninitialized {
                try await controller.bootstrap(licenseKey: licenseKey)
            }

            try await controller.startCamera(includeAudio: false)
            state = .running
            applyDebugCaptureModeIfNeeded()
            markFaceVisibleForDebugAppShellIfNeeded()
        } catch DeepARController.SetupError.missingLicenseKey {
            state = .failed(.licenseInvalid)
            lastError = .licenseInvalid
            Logger.mirror.error("DeepAR license rejected as missing during bootstrap")
        } catch DeepARController.SetupError.sdkInitTimeout {
            state = .failed(.effectFail)
            lastError = .effectFail
            Logger.mirror.error("DeepAR bootstrap timed out")
        } catch {
            state = .failed(.effectFail)
            lastError = .effectFail
            Logger.deepAR.error("Mirror start failed: \(error.localizedDescription)")
        }
    }

    func handleScenePhase(_ phase: ScenePhase) async {
        switch phase {
        case .active:
            await resumeFromBackgroundIfNeeded()
        case .background:
            await retainForBackground()
        case .inactive:
            break
        @unknown default:
            break
        }
    }

    func pause() {
        backgroundReleaseTask?.cancel()
        backgroundReleaseTask = nil
        faceTask?.cancel()
        faceTask = nil
        removeErrorActionObservers()
        noFaceErrorTask?.cancel()
        noFaceErrorTask = nil
        captureTickTask?.cancel()
        captureTickTask = nil
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingStart = nil
        capturePressStartedAt = nil
        activeCaptureMode = .idle
        videoRecording.reset()
        pendingPreviewAsset = nil
        previewRouteID = nil
        pendingRecordingProGateClipURL = nil
        recordingProGateRouteID = nil
        isFaceDetected = false
        lastCaptureFailureKind = nil
        isApplyingSelection = false
        appliedParameterValues.removeAll()

        if state == .running || state == .starting {
            Task { @MainActor [controller] in
                await controller.stopCamera()
            }
            state = .idle
        }
    }

    func refreshCameraAuthorization() async {
        guard let env else {
            return
        }

        let status = await env.permissions.cameraStatus()

        switch status {
        case .granted:
            if pendingFullScreenError == .camDenied {
                pendingFullScreenError = nil
            }

            if state == .needsPermission {
                await start(env: env)
            }
        case .denied, .restricted:
            state = .needsPermission
            pendingFullScreenError = .camDenied
        case .notDetermined:
            state = .needsPermission
        }
    }

    func canUseProContent(isPro: Bool) -> Bool {
        guard isPro else {
            return true
        }
        return entitlements.isPro
    }

    func escalateEffectFailure() {
        state = .failed(.effectFail)
    }

    func retryLastEffect() async {
        switch lastEffectIntent {
        case .shade(let slot, let shade):
            await selectShade(in: slot, shade: shade)
        case .look(let look):
            await selectLook(look)
        case nil:
            break
        }
    }

    func retryLastCaptureFailure() async {
        switch lastCaptureFailureKind {
        case .photo:
            await capturePhoto()
        case .video:
            await startVideoRecording(forceNoAudio: false)
        case nil:
            break
        }
    }

    func useSampleFaceIfAvailable() async {
        guard let sampleFaceLoader else {
            Logger.mirror.info("DEBUG sample face requested but no loader is configured")
            return
        }

        let loaded = await sampleFaceLoader()
        if loaded {
            onFaceDetected(true)
        } else {
            Logger.mirror.info("DEBUG sample face requested but no bundled sample was available")
        }
    }

    var shouldSkipControllerCallsForSimulator: Bool {
        #if targetEnvironment(simulator)
        controller.state != .ready
        #else
        false
        #endif
    }

    static var defaultUsesSimulatorPlaceholder: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    private func observeFaceVisibility() {
        faceTask?.cancel()
        let stream = controller.faceVisibilityStream
        onFaceDetected(controller.trackedFace)
        faceTask = Task { @MainActor [weak self] in
            for await visible in stream {
                guard let self else {
                    return
                }
                self.onFaceDetected(visible)
            }
        }
    }

    private func prepareCameraPermission(using env: AppEnvironment) async -> Bool {
        let cameraStatus = await env.permissions.cameraStatus()
        guard cameraStatus == .granted else {
            state = .needsPermission
            if cameraStatus == .denied || cameraStatus == .restricted {
                pendingFullScreenError = .camDenied
            }
            Logger.deepAR.info("Mirror camera permission needed: \(String(describing: cameraStatus))")
            return false
        }

        return true
    }

    private func observeErrorActions() {
        observeRecordWithoutAudio()
        observeRetryEffectLoad()
        observeRetryRecording()
        observeUseSampleFace()
    }

    private func removeErrorActionObservers() {
        if let recordWithoutAudioObserver {
            notificationCenter.removeObserver(recordWithoutAudioObserver)
            self.recordWithoutAudioObserver = nil
        }

        if let retryEffectObserver {
            notificationCenter.removeObserver(retryEffectObserver)
            self.retryEffectObserver = nil
        }

        if let retryRecordingObserver {
            notificationCenter.removeObserver(retryRecordingObserver)
            self.retryRecordingObserver = nil
        }

        if let useSampleFaceObserver {
            notificationCenter.removeObserver(useSampleFaceObserver)
            self.useSampleFaceObserver = nil
        }
    }

    private func applyDebugCaptureModeIfNeeded() {
        #if DEBUG
        guard ProcessInfo.processInfo.arguments.contains("-GRWMDebugCaptureRecording") else {
            return
        }

        activeCaptureMode = .videoRecording(secondsElapsed: 5)
        #endif
    }

    private func retainForBackground() async {
        backgroundReleaseTask?.cancel()
        backgroundReleaseTask = nil

        guard !usesSimulatorPlaceholder, controller.state == .ready else {
            return
        }

        await controller.suspendForBackground()
        backgroundReleaseTask = Task { @MainActor [weak self] in
            guard let self else {
                return
            }

            try? await Task.sleep(for: self.backgroundRetention)
            guard !Task.isCancelled else {
                return
            }

            await self.controller.shutdownEngine()
            self.effectTextureCache.removeAll()
            self.state = .idle
            Logger.performance.info("Released retained mirror resources after background timeout")
        }
    }

    private func resumeFromBackgroundIfNeeded() async {
        backgroundReleaseTask?.cancel()
        backgroundReleaseTask = nil

        guard !usesSimulatorPlaceholder else {
            return
        }

        if controller.state == .ready, state == .running {
            do {
                try await controller.resumeFromBackground(includeAudio: false)
            } catch {
                Logger.performance.error(
                    "Mirror resume failed after background: \(error.localizedDescription, privacy: .public)"
                )
                if let env {
                    await start(env: env)
                }
            }
            return
        }

        if controller.state == .uninitialized, let env {
            await start(env: env)
        }
    }

    private func observeRecordWithoutAudio() {
        guard recordWithoutAudioObserver == nil else {
            return
        }

        recordWithoutAudioObserver = notificationCenter.addObserver(
            forName: .recordWithoutAudio,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }

                await self.startVideoRecording(forceNoAudio: true)
            }
        }
    }

    private func observeRetryEffectLoad() {
        guard retryEffectObserver == nil else {
            return
        }

        retryEffectObserver = notificationCenter.addObserver(
            forName: .retryEffectLoad,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }

                await self.retryLastEffect()
            }
        }
    }

    private func observeRetryRecording() {
        guard retryRecordingObserver == nil else {
            return
        }

        retryRecordingObserver = notificationCenter.addObserver(
            forName: .retryRecording,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }

                await self.retryLastCaptureFailure()
            }
        }
    }

    private func observeUseSampleFace() {
        guard useSampleFaceObserver == nil else {
            return
        }

        useSampleFaceObserver = notificationCenter.addObserver(
            forName: .useSampleFace,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }

                await self.useSampleFaceIfAvailable()
            }
        }
    }
}

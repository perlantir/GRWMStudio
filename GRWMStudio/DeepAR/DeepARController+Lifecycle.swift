import AVFoundation
import OSLog
import UIKit

extension DeepARController {
    func suspendForBackground() async {
        guard state == .ready else {
            return
        }
        cameraController?.stopCamera()
        cameraController = nil
        _client?.pauseRendering()
        cameraIncludesAudio = false
        trackedFace = false
        Logger.deepAR.info("DeepAR session suspended for background")
    }

    func resumeFromBackground(includeAudio: Bool) async throws {
        guard state == .ready else {
            throw SetupError.recordingFailed(reason: "DeepAR not ready")
        }
        _client?.resumeRendering()
        try await startCamera(includeAudio: includeAudio)
        Logger.deepAR.info("DeepAR session resumed from background")
    }

    func shutdownEngine() async {
        await stopCamera()
        _client?.pauseRendering()
        _client?.shutdown()
        failPendingEffectLoads(reason: "Shutdown")
        failCaptureAndRecording(reason: "Shutdown")
        loadEffectContinuations.removeAll()
        loadEffectRequestIDs.removeAll()
        loadedEffects.removeAll()
        _delegateProxy = nil
        _client = nil
        _deepAR = nil
        _arView = nil
        bootstrapContinuation = nil
        state = .uninitialized
        trackedFace = false
        cameraIncludesAudio = false
        Logger.deepAR.info("DeepAR engine shut down")
    }

    func configureCameraController() {
        cameraController?.preset = AVCaptureSession.Preset.hd1280x720
        cameraController?.videoOrientation = AVCaptureVideoOrientation.portrait
    }

    static var previewResolution: CGSize {
        CGSize(width: 1280, height: 720)
    }
}

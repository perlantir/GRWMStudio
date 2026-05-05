import CoreMedia
import DeepAR
import OSLog
import UIKit

final class DeepARDelegateProxy: NSObject, DeepARDelegate {
    weak var controller: DeepARController?

    init(controller: DeepARController) {
        self.controller = controller
        super.init()
    }

    func didTakeScreenshot(_ screenshot: UIImage) {
        Logger.deepAR.info("didTakeScreenshot")
        Task { @MainActor [weak controller] in
            guard let controller else {
                return
            }
            controller.completePhotoCapture(with: screenshot)
        }
    }

    func didInitialize() {
        Logger.deepAR.info("DeepAR didInitialize")
        Task { [weak controller] in
            await controller?.completeBootstrapFromDelegate()
        }
    }

    func faceVisiblityDidChange(_ faceVisible: Bool) {
        Task { [weak controller] in
            await controller?.updateTrackedFace(faceVisible)
        }
    }

    func frameAvailable(_ sampleBuffer: CMSampleBuffer) {}

    func faceTracked(_ faceData: MultiFaceData) {}

    func number(ofFacesVisibleChanged facesVisible: Int) {}

    func didFinishShutdown() {
        Logger.deepAR.info("DeepAR didFinishShutdown")
    }

    func imageVisibilityChanged(_ gameObjectName: String, imageVisible: Bool) {}

    func didSwitchEffect(_ slot: String) {
        Task { [weak controller] in
            await controller?.completeEffectLoad(slotRawValue: slot)
        }
    }

    func animationTransitioned(toState state: String) {}

    func didStartVideoRecording() {
        Logger.deepAR.info("didStartVideoRecording")
    }

    func didFinishPreparingForVideoRecording() {}

    func didFinishVideoRecording(_ videoFilePath: String) {
        Logger.deepAR.info("didFinishVideoRecording: \(videoFilePath, privacy: .public)")
        Task { @MainActor [weak controller] in
            await controller?.completeVideoRecording(sourcePath: videoFilePath)
        }
    }

    func recordingFailedWithError(_ error: Error) {
        Logger.deepAR.error("recordingFailedWithError: \(error.localizedDescription, privacy: .public)")
        Task { @MainActor [weak controller] in
            controller?.failCaptureAndRecording(reason: error.localizedDescription)
        }
    }

    func onError(withCode code: ARErrorType, error: String) {
        Logger.deepAR.error("DeepAR error \(String(describing: code), privacy: .public): \(error, privacy: .public)")
        Task { [weak controller] in
            await controller?.failPendingEffectLoads(reason: error)
        }
    }
}

import Foundation
import UIKit

@MainActor
enum ErrorRouter {
    static func handleCTA(_ variant: ErrorVariant, coordinator: RootCoordinator) {
        switch variant {
        case .camDenied, .micDenied, .photoDenied:
            coordinator.dismissError()
            openSettings()
        case .license:
            coordinator.dismissError()
            coordinator.startParentGate(intent: .paywall(source: .proShade))
        case .licenseInvalid:
            coordinator.dismissError()
        case .effectFail:
            NotificationCenter.default.post(name: .retryEffectLoad, object: nil)
            coordinator.dismissError()
        case .recFail:
            NotificationCenter.default.post(name: .retryRecording, object: nil)
            coordinator.dismissError()
        case .saveFail:
            NotificationCenter.default.post(name: .retrySave, object: nil)
            coordinator.dismissError()
        case .noFace:
            coordinator.dismissError()
        case .lowStorage:
            coordinator.dismissError()
            openSettings()
        }
    }

    static func handleAlt(_ variant: ErrorVariant, coordinator: RootCoordinator) {
        coordinator.dismissError()

        switch variant {
        case .micDenied:
            NotificationCenter.default.post(name: .recordWithoutAudio, object: nil)
        case .photoDenied:
            NotificationCenter.default.post(name: .keepInsideGRWM, object: nil)
        case .effectFail:
            NotificationCenter.default.post(name: .pickDifferentLook, object: nil)
        case .saveFail:
            NotificationCenter.default.post(name: .discardCapture, object: nil)
        case .noFace:
            NotificationCenter.default.post(name: .useSampleFace, object: nil)
        case .lowStorage:
            NotificationCenter.default.post(name: .lockerEnterDeleteMode, object: nil)
        default:
            break
        }
    }

    private static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(url)
    }
}

extension Notification.Name {
    static let retryEffectLoad = Notification.Name("dh.retryEffectLoad")
    static let retryRecording = Notification.Name("dh.retryRecording")
    static let retrySave = Notification.Name("dh.retrySave")
    static let recordWithoutAudio = Notification.Name("dh.recordWithoutAudio")
    static let keepInsideGRWM = Notification.Name("dh.keepInsideGRWM")
    static let pickDifferentLook = Notification.Name("dh.pickDifferentLook")
    static let discardCapture = Notification.Name("dh.discardCapture")
    static let useSampleFace = Notification.Name("dh.useSampleFace")
    static let lockerEnterDeleteMode = Notification.Name("dh.lockerEnterDeleteMode")
}

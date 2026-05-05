import Foundation
import SwiftUI

enum CaptureKind: String, CaseIterable, Identifiable {
    case photo
    case video

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .photo:
            L10n.string("capture.kind.photo")
        case .video:
            L10n.string("capture.kind.video")
        }
    }

    var systemName: String {
        switch self {
        case .photo:
            "camera.fill"
        case .video:
            "video.fill"
        }
    }
}

enum CaptureMode: Equatable {
    case idle
    case photoFiring
    case videoCountdown
    case videoRecording(secondsElapsed: Double)
    case disabled

    var isInteractive: Bool {
        self != .disabled
    }
}

enum CaptureEvent: Equatable {
    case photoCapture
    case videoCapture(duration: Double)
}

struct CapturePressClassifier {
    static let longPressThreshold: TimeInterval = 0.3
    static let maxVideoDuration: TimeInterval = 15

    func event(for pressDuration: TimeInterval) -> CaptureEvent {
        let duration = max(0, pressDuration)
        guard duration > Self.longPressThreshold else {
            return .photoCapture
        }

        return .videoCapture(duration: min(duration, Self.maxVideoDuration))
    }
}

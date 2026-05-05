import CoreHaptics
import UIKit

enum DHHapticKind {
    case tap
    case pop
    case shutter
    case saved
    case errorSoft
    case heavy
}

@MainActor
final class DHHaptics {
    static let shared = DHHaptics()

    private lazy var lightImpact = UIImpactFeedbackGenerator(style: .light)
    private lazy var mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private lazy var heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private lazy var rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private lazy var notification = UINotificationFeedbackGenerator()

    private let supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics

    private var enabled: Bool {
        supportsHaptics && !UIAccessibility.isReduceMotionEnabled && SettingsPreferences.hapticsEnabled
    }

    private init() {}

    func fire(_ kind: DHHapticKind) {
        guard enabled else {
            return
        }

        switch kind {
        case .tap:
            lightImpact.prepare()
            lightImpact.impactOccurred()
        case .pop:
            mediumImpact.prepare()
            mediumImpact.impactOccurred(intensity: 0.7)
        case .shutter:
            rigidImpact.prepare()
            rigidImpact.impactOccurred()
        case .saved:
            notification.prepare()
            notification.notificationOccurred(.success)
        case .errorSoft:
            notification.prepare()
            notification.notificationOccurred(.warning)
        case .heavy:
            heavyImpact.prepare()
            heavyImpact.impactOccurred()
        }
    }
}

extension DHHaptics {
    static func tap() {
        shared.fire(.tap)
    }

    static func light() {
        shared.fire(.tap)
    }

    static func tapMedium() {
        shared.fire(.pop)
    }

    static func medium() {
        shared.fire(.pop)
    }

    static func heavy() {
        shared.fire(.heavy)
    }

    static func success() {
        shared.fire(.saved)
    }

    static func warning() {
        shared.fire(.errorSoft)
    }
}

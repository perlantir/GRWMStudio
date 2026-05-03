import Foundation
import Observation

@MainActor
@Observable
final class OnboardingState {
    private let defaults: UserDefaults
    private let completionKey = "dh_onboarding_complete"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        get {
            defaults.bool(forKey: completionKey)
        }
        set {
            defaults.set(newValue, forKey: completionKey)
        }
    }

    func reset() {
        defaults.removeObject(forKey: completionKey)
    }
}

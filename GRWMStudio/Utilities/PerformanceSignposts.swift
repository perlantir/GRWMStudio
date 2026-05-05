import OSLog

@MainActor
enum PerformanceSignposts {
    private static let signposter = OSSignposter(logger: .performance)

    private static var appLaunchInterval: OSSignpostIntervalState?
    private static var deepARBootstrapInterval: OSSignpostIntervalState?
    private static var deepARStartCameraInterval: OSSignpostIntervalState?
    private static var deepARLoadEffectInterval: OSSignpostIntervalState?
    private static var applyShadeInterval: OSSignpostIntervalState?

    static func beginAppLaunchIfNeeded() {
        guard appLaunchInterval == nil else {
            return
        }
        appLaunchInterval = signposter.beginInterval("App Launch")
    }

    static func endAppLaunchOnMirrorFirstFrame() {
        guard let interval = appLaunchInterval else {
            return
        }
        signposter.endInterval("App Launch", interval)
        appLaunchInterval = nil
    }

    static func beginDeepARBootstrap() {
        guard deepARBootstrapInterval == nil else {
            return
        }
        deepARBootstrapInterval = signposter.beginInterval("DeepAR Bootstrap")
    }

    static func endDeepARBootstrap() {
        guard let interval = deepARBootstrapInterval else {
            return
        }
        signposter.endInterval("DeepAR Bootstrap", interval)
        deepARBootstrapInterval = nil
    }

    static func beginDeepARStartCamera() {
        guard deepARStartCameraInterval == nil else {
            return
        }
        deepARStartCameraInterval = signposter.beginInterval("DeepAR Start Camera")
    }

    static func endDeepARStartCamera() {
        guard let interval = deepARStartCameraInterval else {
            return
        }
        signposter.endInterval("DeepAR Start Camera", interval)
        deepARStartCameraInterval = nil
    }

    static func beginDeepARLoadEffect() {
        guard deepARLoadEffectInterval == nil else {
            return
        }
        deepARLoadEffectInterval = signposter.beginInterval("DeepAR Load Effect")
    }

    static func endDeepARLoadEffect() {
        guard let interval = deepARLoadEffectInterval else {
            return
        }
        signposter.endInterval("DeepAR Load Effect", interval)
        deepARLoadEffectInterval = nil
    }

    static func beginApplyShade() {
        guard applyShadeInterval == nil else {
            return
        }
        applyShadeInterval = signposter.beginInterval("Mirror Apply Shade")
    }

    static func endApplyShade() {
        guard let interval = applyShadeInterval else {
            return
        }
        signposter.endInterval("Mirror Apply Shade", interval)
        applyShadeInterval = nil
    }
}

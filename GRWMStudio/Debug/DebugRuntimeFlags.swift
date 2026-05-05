import Foundation

enum DebugRuntimeFlags {
    static func contains(_ flag: String) -> Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains(flag)
        #else
        false
        #endif
    }

    static func delay(
        _ defaultDuration: Duration,
        slowFlag: String,
        slowedDuration: Duration = .seconds(2.4)
    ) -> Duration {
        contains(slowFlag) ? slowedDuration : defaultDuration
    }
}

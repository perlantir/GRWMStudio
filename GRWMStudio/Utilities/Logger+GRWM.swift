import OSLog

extension Logger {
    static let app = Logger(subsystem: "app.grwmstudio.ios", category: "app")
    static let deepAR = Logger(subsystem: "app.grwmstudio.ios", category: "deepar")
    static let mirror = Logger(subsystem: "app.grwmstudio.ios", category: "mirror")
    static let performance = Logger(subsystem: "app.grwmstudio.ios", category: "performance")
    static let capture = Logger(subsystem: "app.grwmstudio.ios", category: "capture")
    static let perms = Logger(subsystem: "app.grwmstudio.ios", category: "permissions")
    static let persist = Logger(subsystem: "app.grwmstudio.ios", category: "persistence")
    static let storeKit = Logger(subsystem: "app.grwmstudio.ios", category: "storekit")
    static let feed = Logger(subsystem: "app.grwmstudio.ios", category: "feed")
}

import SwiftData
import SwiftUI

@main
struct GRWMStudioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var environment = AppEnvironment()
    @State private var coordinator = RootCoordinator()

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-GRWMUITestResetState") {
            UserDefaults.standard.removeObject(forKey: ProEntitlements.cacheKey)
            UserDefaults.standard.removeObject(forKey: "dh_last_tab")
            UserDefaults.standard.set(true, forKey: "dh_seen_look_tutorial")
        }
        #endif

        PerformanceSignposts.beginAppLaunchIfNeeded()
        _ = ProEntitlementsHolder.shared
    }

    var body: some Scene {
        WindowGroup {
            RootContainer()
                .environment(\.appEnvironment, environment)
                .environment(\.rootCoordinator, coordinator)
                .environment(ProEntitlementsHolder.shared.entitlements)
                .modelContainer(AppModelContainer.container)
                .preferredColorScheme(.light)
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        }
    }
}

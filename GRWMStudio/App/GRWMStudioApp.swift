import SwiftData
import SwiftUI

@main
struct GRWMStudioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var environment = AppEnvironment()
    @State private var coordinator = RootCoordinator()

    init() {
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

import SwiftData
import SwiftUI

@main
struct GRWMStudioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var environment = AppEnvironment()
    @State private var coordinator = RootCoordinator()

    var body: some Scene {
        WindowGroup {
            RootContainer()
                .environment(\.appEnvironment, environment)
                .environment(\.rootCoordinator, coordinator)
                .modelContainer(AppModelContainer.container)
                .preferredColorScheme(.light)
        }
    }
}

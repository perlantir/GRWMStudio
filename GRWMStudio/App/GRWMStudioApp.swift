import SwiftUI

@main
struct GRWMStudioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            Color(red: 1.0, green: 0.898, blue: 0.949)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
        }
    }
}

import SwiftUI

struct RootContainer: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.rootCoordinator) private var coordinator

    var body: some View {
        ZStack {
            DHWallpaperGradient()
            routeView
        }
        .preferredColorScheme(.light)
    }

    @ViewBuilder
    private var routeView: some View {
        switch coordinator.route {
        case .onboardingSplash:
            placeholder("Splash placeholder")
        case .onboardingWelcome:
            placeholder("Welcome placeholder")
        case .onboardingParentInfo:
            placeholder("Parent Info placeholder")
        case .onboardingPermissions:
            placeholder("Permissions placeholder")
        case .onboardingPermissionsDenied:
            placeholder("Permissions Denied placeholder")
        case .app:
            placeholder("App placeholder")
        case .parentalGate(let reason):
            placeholder("Parental Gate: \(String(describing: reason))")
        case .paywall(let source):
            placeholder("Paywall: \(String(describing: source))")
        case .error(let variant):
            placeholder("Error: \(String(describing: variant))")
        }
    }

    private func placeholder(_ title: String) -> some View {
        Text(title)
            .font(DH.font(.headline))
            .tracking(DH.tracking(.headline))
            .foregroundStyle(DH.pinkDeep)
            .padding(24)
    }
}

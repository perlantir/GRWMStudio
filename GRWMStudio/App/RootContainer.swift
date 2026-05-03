import OSLog
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
        .task {
            resolveInitialRoute()
            await loadEffectCatalog()
        }
    }

    @ViewBuilder
    private var routeView: some View {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-GRWMDebugDeepARViewInitializing") {
            DeepARViewDebugScreen(mode: .initializing)
        } else if ProcessInfo.processInfo.arguments.contains("-GRWMDebugDeepARView") {
            DeepARViewDebugScreen()
        } else {
            routedContent
        }
        #else
        routedContent
        #endif
    }

    @ViewBuilder
    private var routedContent: some View {
        switch coordinator.route {
        case .onboardingSplash:
            SplashView()
        case .onboardingWelcome:
            placeholder("Welcome placeholder")
        case .onboardingParentInfo:
            placeholder("Parent Info placeholder")
        case .onboardingPermissions:
            placeholder("Permissions placeholder")
        case .onboardingPermissionsDenied:
            placeholder("Permissions Denied placeholder")
        case .app:
            appPlaceholder
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

    @ViewBuilder
    private var appPlaceholder: some View {
        #if DEBUG
        VStack(spacing: 16) {
            placeholder("App placeholder")
            DHButton(title: "Reset Onboarding", kind: .ghost, size: .sm) {
                env.onboarding.reset()
                coordinator.route = .onboardingSplash
            }
            .accessibilityLabel("Reset onboarding")
        }
        #else
        placeholder("App placeholder")
        #endif
    }

    private func resolveInitialRoute() {
        if env.onboarding.hasCompletedOnboarding {
            coordinator.route = .app
        } else if coordinator.route == .app {
            coordinator.route = .onboardingSplash
        }
    }

    private func loadEffectCatalog() async {
        do {
            _ = try await EffectCatalog.shared.load()
            Logger.deepAR.info("Effect catalog loaded")
        } catch {
            Logger.deepAR.error("Catalog load failed: \(error.localizedDescription)")
            coordinator.presentError(.effectFail)
        }
    }
}

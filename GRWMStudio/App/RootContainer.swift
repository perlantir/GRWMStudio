import OSLog
import SwiftUI

struct RootContainer: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.rootCoordinator) private var coordinator

    var body: some View {
        ZStack {
            DHWallpaperGradient()
            routeView
            overlayView
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
        if ProcessInfo.processInfo.arguments.contains("-GRWMDebugCountdownOverlay") {
            CountdownOverlayDebugScreen()
        } else if ProcessInfo.processInfo.arguments.contains("-GRWMDebugDeepARViewInitializing") {
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
            WelcomeView()
        case .onboardingParentInfo:
            ParentInfoView()
        case .onboardingPermissions:
            PermissionsView()
        case .onboardingPermissionsDenied:
            PermissionsDeniedView()
        case .app:
            AppShell()
        case .preview:
            if let asset = coordinator.previewAsset {
                PreviewPlaceholderView(asset: asset) {
                    coordinator.dismissPreview()
                }
            } else {
                placeholder("Preview unavailable")
            }
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
    private var overlayView: some View {
        if let overlay = coordinator.overlay {
            switch overlay {
            case .parentGate(let intent):
                PlaceholderParentGateView(intent: intent) {
                    switch intent {
                    case .paywall:
                        coordinator.paywallShown()
                    case .settings, .deletion:
                        coordinator.dismissOverlay()
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))

            case .paywall:
                PlaceholderPaywallView {
                    coordinator.dismissOverlay()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
    }

    private func resolveInitialRoute() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-GRWMDebugAppShell") {
            coordinator.route = .app
            return
        }

        if ProcessInfo.processInfo.arguments.contains("-GRWMDebugOnboardingFlow") {
            return
        }
        #endif

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

private struct PlaceholderParentGateView: View {
    let intent: RootCoordinator.ParentGateIntent
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            DH.pinkPaper.opacity(0.96)
                .ignoresSafeArea()

            DHCard(bg: DH.cream, deep: DH.pinkDeep, cornerRadius: DH.Radius.bigCard, padding: 24) {
                VStack(spacing: 16) {
                    StickerHeart(size: 38, fill: DH.pink, stroke: .white, strokeWidth: 3)

                    Text("Parent gate placeholder — wired in GRWM-700")
                        .font(DH.font(.headline))
                        .tracking(DH.tracking(.headline))
                        .foregroundStyle(DH.ink)
                        .multilineTextAlignment(.center)

                    DHButton(title: "Done", kind: .primary, size: .md, action: onComplete)
                        .accessibilityLabel("Done")
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 22)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Parent gate placeholder")
    }
}

private struct PlaceholderPaywallView: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            DHWallpaperGradient()
                .ignoresSafeArea()

            DHCard(bg: .white, deep: DH.pinkDeep, cornerRadius: DH.Radius.bigCard, padding: 24) {
                VStack(spacing: 16) {
                    StickerStar(size: 42, fill: DH.butter, stroke: .white, strokeWidth: 3)

                    Text("Paywall — wired in GRWM-705")
                        .font(DH.font(.headline))
                        .tracking(DH.tracking(.headline))
                        .foregroundStyle(DH.ink)
                        .multilineTextAlignment(.center)

                    DHButton(title: "Done", kind: .primary, size: .md, action: onDismiss)
                        .accessibilityLabel("Dismiss paywall")
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 22)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Paywall placeholder")
    }
}

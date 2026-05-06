import Observation
import OSLog
import SwiftData
import SwiftUI

struct RootContainer: View {
    @Environment(\.appEnvironment) var env
    @Environment(\.modelContext) var modelContext
    @Environment(\.rootCoordinator) var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator

        ZStack {
            DHWallpaperGradient()
            routeView
            overlayView
            errorOverlay
            toastOverlay
        }
        .preferredColorScheme(.light)
        .fullScreenCover(item: $coordinator.presentedParentGate) { intent in
            ParentGateRootView(
                coordinator: ParentGateCoordinator(
                    intent: intent,
                    onPass: { coordinator.parentGatePassed($0) },
                    onCancel: { coordinator.dismissParentGate() }
                )
            )
        }
        .fullScreenCover(item: $coordinator.presentedPaywallSource) { source in
            DHPaywallView(
                source: source,
                onDismiss: {
                    coordinator.dismissPaywall()
                }
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .retrySave)) { _ in
            guard let asset = coordinator.previewAsset else {
                return
            }

            Task { @MainActor in
                await savePreview(asset: asset)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .discardCapture)) { _ in
            discardPreviewAssetAndReturnToMirror()
        }
        .onReceive(NotificationCenter.default.publisher(for: .lockerEnterDeleteMode)) { _ in
            discardPreviewAssetAndReturnToMirror()
        }
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
                previewView(for: asset)
            } else {
                placeholder(L10n.string("preview.unavailable"))
            }
        case .parentalGate:
            AppShell()
        case .paywall:
            AppShell()
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
            case .preview:
                if let asset = coordinator.previewAsset {
                    previewView(for: asset)
                    .transition(.opacity)
                }

            case .savedConfetti:
                SavedConfetti {
                    coordinator.finishPreviewSaved()
                }
                .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private var toastOverlay: some View {
        if let message = coordinator.toastMessage {
            ToastView(message: message)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 124)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .accessibilityIdentifier("root-toast")
        }
    }

    @ViewBuilder
    private var errorOverlay: some View {
        if let variant = coordinator.presentedError {
            DHErrorView(
                variant: variant,
                onCTA: {
                    ErrorRouter.handleCTA(variant, coordinator: coordinator)
                },
                onAlt: {
                    ErrorRouter.handleAlt(variant, coordinator: coordinator)
                },
                onClose: {
                    coordinator.dismissError()
                }
            )
            .zIndex(20)
            .transition(.opacity)
        }
    }
}

import Observation
import OSLog
import SwiftData
import SwiftUI

struct RootContainer: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.modelContext) private var modelContext
    @Environment(\.rootCoordinator) private var coordinator
    @State private var isSharingPreview = false
    @State private var previewShareItems: [Any] = []

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
        .sheet(isPresented: $isSharingPreview) {
            ActivityShareSheet(items: previewShareItems)
                .ignoresSafeArea()
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

    private func previewView(for asset: CapturedAsset) -> some View {
        PreviewPlaceholderView(
            asset: asset,
            lookName: coordinator.previewLookName,
            onSave: {
                await savePreview(asset: asset)
            },
            onShare: {
                sharePreview(asset)
            },
            onDiscard: {
                discardPreviewAssetAndReturnToMirror()
            }
        )
    }

    private func savePreview(asset: CapturedAsset) async {
        guard StorageMonitor.canSave else {
            coordinator.presentError(.lowStorage)
            return
        }

        let service = CaptureSaveService(modelContext)
        do {
            _ = try await service.save(
                asset: asset,
                lookName: coordinator.previewLookName,
                shadeIDs: coordinator.previewShadeIDs
            )

            if SettingsPreferences.saveToPhotos {
                do {
                    try await PhotoLibrarySaver().save(asset: asset)
                    coordinator.showToast(L10n.string("root.toast.saved_locker_and_photos"))
                } catch {
                    coordinator.showToast(L10n.string("root.toast.saved_locker_photos_permission"))
                }
            }

            coordinator.dismissPreviewSaved()
        } catch CaptureServiceError.capacityExceeded {
            coordinator.presentError(.lowStorage)
        } catch CaptureServiceError.lockerAtLimit {
            coordinator.startParentGate(intent: .paywall(source: .lockerLimit))
        } catch {
            coordinator.presentError(.saveFail)
        }
    }

    private func discardPreviewAssetAndReturnToMirror() {
        if case .video(let url) = coordinator.previewAsset {
            try? FileManager.default.removeItem(at: url)
        }
        coordinator.dismissPreview()
    }

    private func sharePreview(_ asset: CapturedAsset) {
        guard !SettingsPreferences.blockShareExtensions else {
            coordinator.showToast(L10n.string("save_share.sharing_blocked"))
            return
        }

        switch asset {
        case .photo(let image):
            previewShareItems = [image]
        case .video(let url):
            previewShareItems = [url]
        }
        isSharingPreview = true
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

import OSLog
import SwiftUI

struct MirrorView: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.rootCoordinator) private var coordinator
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var viewModel: MirrorViewModel
    var onFavoriteLooks: @MainActor () -> Void = {}
    @State private var pendingCategoryAfterLook: FilterCategory?
    @State private var showNoFaceTip = false
    @State private var noFaceTipTask: Task<Void, Never>?
    @State private var hasSeenFace = false

    var body: some View {
        ZStack {
            DHWallpaperGradient()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                MirrorChrome.top(onFavoriteLooks: onFavoriteLooks) {
                    Task { @MainActor in
                        await viewModel.resetAll()
                        pendingCategoryAfterLook = nil
                    }
                }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)

                cameraRegion
                    .overlay(alignment: .top) {
                        cameraTopOverlay
                    }
                    .overlay(alignment: .topLeading) {
                        recordingOverlay
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 12)

                Spacer(minLength: 220)
            }

            MirrorTrayHostView(
                viewModel: viewModel,
                pendingCategoryAfterLook: $pendingCategoryAfterLook
            )

            countdownOverlay
            flashOverlay
        }
        .preferredColorScheme(.light)
        .task {
            await viewModel.start(env: env)
            presentPendingFullScreenErrorIfNeeded()
            updateNoFaceTip(for: viewModel.isFaceDetected)
        }
        .onChange(of: viewModel.pendingFullScreenError) { _, _ in
            presentPendingFullScreenErrorIfNeeded()
        }
        .onChange(of: coordinator.presentedError) { _, _ in
            presentPendingFullScreenErrorIfNeeded()
        }
        .onChange(of: viewModel.isFaceDetected) { _, visible in
            if visible {
                hasSeenFace = true
            }
            updateNoFaceTip(for: visible)
        }
        .onChange(of: viewModel.state) { _, state in
            if state == .running {
                Task { @MainActor in
                    await Task.yield()
                    PerformanceSignposts.endAppLaunchOnMirrorFirstFrame()
                }
            }
            guard state == .running else {
                noFaceTipTask?.cancel()
                withAnimation(DHAnim.respecting(.quickFade, reduceMotion: reduceMotion)) {
                    showNoFaceTip = false
                }
                return
            }

            updateNoFaceTip(for: viewModel.isFaceDetected)
        }
        .onChange(of: viewModel.previewRouteID) { _, newValue in
            guard newValue != nil, let asset = viewModel.pendingPreviewAsset else {
                return
            }

            coordinator.showPreview(
                asset: asset,
                lookName: viewModel.activeLookName,
                shadeIDs: viewModel.selectedCaptureShadeIDs
            )
            viewModel.pendingPreviewAsset = nil
            viewModel.previewRouteID = nil
        }
        .onChange(of: scenePhase) { _, newPhase in
            Task { @MainActor in
                await viewModel.handleScenePhase(newPhase)

                if newPhase == .active {
                    await viewModel.refreshCameraAuthorization()
                    if coordinator.presentedError == .camDenied,
                       await env.permissions.cameraStatus() == .granted {
                        coordinator.dismissError()
                    }
                    presentPendingFullScreenErrorIfNeeded()
                }
            }
        }
        .onDisappear {
            noFaceTipTask?.cancel()
            guard scenePhase == .active else {
                return
            }
            viewModel.pause()
        }
    }

    @ViewBuilder
    private var countdownOverlay: some View {
        if viewModel.captureMode == .videoCountdown {
            CountdownOverlay {
                Task { @MainActor in
                    await viewModel.videoCountdownComplete()
                }
            } onCancel: {
                viewModel.cancelVideoCountdown()
            }
            .transition(.opacity)
        }
    }

    @ViewBuilder
    private var flashOverlay: some View {
        if viewModel.flashEnabled {
            Color.white
                .opacity(0.5)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .transition(.opacity)
        }
    }

    @ViewBuilder
    private var cameraTopOverlay: some View {
        if showNoFaceTip {
            NoFaceTipView()
                .padding(.top, 18)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    @ViewBuilder
    private var recordingOverlay: some View {
        if case .videoRecording(let secondsElapsed) = viewModel.captureMode {
            RecordingOverlay(secondsElapsed: secondsElapsed)
                .transition(.scale.combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var cameraRegion: some View {
        switch viewModel.state {
        case .idle, .starting, .running:
            DeepARView(controller: viewModel.controller)
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: DH.Radius.viewportInner))
                .overlay {
                    RoundedRectangle(cornerRadius: DH.Radius.viewportInner)
                        .strokeBorder(.white, lineWidth: 6)
                }
                .overlay {
                    if viewModel.state == .starting {
                        DHSpinner()
                    }
                }
                .chunkyShadow(.lg(deep: DH.pinkDeep), shape: RoundedRectangle(cornerRadius: DH.Radius.viewportInner))
                .accessibilityLabel(L10n.string("mirror.camera.accessibility_label"))

        case .needsPermission:
            permissionCard

        case .failed(let variant):
            DHCard(bg: DH.cream, deep: DH.pink, cornerRadius: DH.Radius.bigCard, padding: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("mirror.failed.title")
                        .font(DH.font(.headline))
                        .tracking(DH.tracking(.headline))
                        .foregroundStyle(DH.pinkDeep)

                    Text(errorMessage(for: variant))
                        .font(DH.font(.body))
                        .foregroundStyle(DH.ink.opacity(0.72))
                        .lineLimit(2)
                }
            }
        }
    }

}

private extension MirrorView {
    var permissionCard: some View {
        DHCard(bg: DH.butter, deep: DH.butterDeep, cornerRadius: DH.Radius.bigCard, padding: 24) {
            HStack(spacing: 14) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(DH.ink)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(.white.opacity(0.65)))

                Text("mirror.permission.title")
                    .font(DH.font(.headline))
                    .tracking(DH.tracking(.headline))
                    .foregroundStyle(DH.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: DH.Radius.bigCard))
        .onTapGesture {
            Logger.deepAR.info("Mirror permission card tapped")
            coordinator.showPermissions()
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(L10n.string("mirror.permission.accessibility_label"))
        .accessibilityHint(L10n.string("mirror.permission.accessibility_hint"))
    }

    func updateNoFaceTip(for visible: Bool) {
        noFaceTipTask?.cancel()

        guard viewModel.state == .running else {
            withAnimation(DHAnim.respecting(.quickFade, reduceMotion: reduceMotion)) {
                showNoFaceTip = false
            }
            return
        }

        if visible {
            hasSeenFace = true
            withAnimation(DHAnim.respecting(.quickFade, reduceMotion: reduceMotion)) {
                showNoFaceTip = false
            }
            return
        }

        guard hasSeenFace else {
            withAnimation(DHAnim.respecting(.quickFade, reduceMotion: reduceMotion)) {
                showNoFaceTip = false
            }
            return
        }

        noFaceTipTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(3000))
            guard !Task.isCancelled else {
                return
            }

            withAnimation(DHAnim.respecting(.bouncy, reduceMotion: reduceMotion)) {
                showNoFaceTip = true
            }
        }
    }

    func presentPendingFullScreenErrorIfNeeded() {
        guard let variant = viewModel.pendingFullScreenError else {
            return
        }

        guard coordinator.presentedError == nil else {
            return
        }

        coordinator.presentError(variant)
        viewModel.pendingFullScreenError = nil
    }
}

#Preview("Mirror View") {
    MirrorView(viewModel: MirrorViewModel())
        .environment(\.appEnvironment, AppEnvironment())
        .environment(\.rootCoordinator, RootCoordinator())
}

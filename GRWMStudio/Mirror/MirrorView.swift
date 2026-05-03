import OSLog
import SwiftUI

struct MirrorView: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.rootCoordinator) private var coordinator
    @Bindable var viewModel: MirrorViewModel
    @State private var pendingCategoryAfterLook: FilterCategory?
    @State private var showNoFaceTip = false
    @State private var noFaceTipTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            DHWallpaperGradient()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                MirrorChrome.top {
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
                    .padding(.horizontal, 14)
                    .padding(.top, 12)

                Spacer(minLength: 220)
            }

            MirrorTrayHostView(
                viewModel: viewModel,
                pendingCategoryAfterLook: $pendingCategoryAfterLook
            )

            effectFailureOverlay
            captureFailureOverlay
            flashOverlay
        }
        .preferredColorScheme(.light)
        .task {
            await viewModel.start(env: env)
            updateNoFaceTip(for: viewModel.isFaceDetected)
        }
        .onChange(of: viewModel.isFaceDetected) { _, visible in
            updateNoFaceTip(for: visible)
        }
        .onChange(of: viewModel.state) { _, state in
            guard state == .running else {
                noFaceTipTask?.cancel()
                withAnimation(.easeOut(duration: 0.18)) {
                    showNoFaceTip = false
                }
                return
            }

            updateNoFaceTip(for: viewModel.isFaceDetected)
        }
        .onChange(of: viewModel.lastError) { _, newValue in
            guard newValue == .license else {
                return
            }

            coordinator.startParentGate(intent: .paywall)
            viewModel.lastError = nil
        }
        .onChange(of: viewModel.previewRouteID) { _, newValue in
            guard newValue != nil, let asset = viewModel.pendingPreviewAsset else {
                return
            }

            coordinator.showPreview(asset: asset)
            viewModel.pendingPreviewAsset = nil
            viewModel.previewRouteID = nil
        }
        .onDisappear {
            noFaceTipTask?.cancel()
            viewModel.pause()
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
        if showNoFaceTip, viewModel.lastError != .effectFail {
            NoFaceTipView()
                .padding(.top, 18)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    @ViewBuilder
    private var effectFailureOverlay: some View {
        if viewModel.state == .running, viewModel.lastError == .effectFail {
            EffectFailureBanner {
                Task { @MainActor in
                    await viewModel.retryLastSelection()
                }
            } onDismiss: {
                Task { @MainActor in
                    viewModel.dismissEffectFailureBanner()
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 80)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    @ViewBuilder
    private var captureFailureOverlay: some View {
        if viewModel.state == .running, viewModel.lastError == .recFail {
            CaptureFailureBanner {
                Task { @MainActor in
                    viewModel.dismissCaptureFailureBanner()
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 80)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .transition(.opacity.combined(with: .move(edge: .top)))
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
                .chunkyShadow(.lg(deep: DH.pinkDeep), shape: RoundedRectangle(cornerRadius: DH.Radius.viewportInner))
                .accessibilityLabel("Magic mirror camera")

        case .needsPermission:
            permissionCard

        case .failed(let variant):
            DHCard(bg: DH.cream, deep: DH.pink, cornerRadius: DH.Radius.bigCard, padding: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mirror needs a restart")
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

    private var permissionCard: some View {
        DHCard(bg: DH.butter, deep: DH.butterDeep, cornerRadius: DH.Radius.bigCard, padding: 24) {
            HStack(spacing: 14) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(DH.ink)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(.white.opacity(0.65)))

                Text("Tap to allow camera 💕")
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
        .accessibilityLabel("Tap to allow camera")
    }

    private func updateNoFaceTip(for visible: Bool) {
        noFaceTipTask?.cancel()

        guard viewModel.state == .running else {
            withAnimation(.easeOut(duration: 0.18)) {
                showNoFaceTip = false
            }
            return
        }

        if visible {
            withAnimation(.easeOut(duration: 0.18)) {
                showNoFaceTip = false
            }
            return
        }

        noFaceTipTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(1500))
            guard !Task.isCancelled else {
                return
            }

            withAnimation(.bouncy(duration: 0.28)) {
                showNoFaceTip = true
            }
        }
    }
}

#Preview("Mirror View") {
    MirrorView(viewModel: MirrorViewModel())
        .environment(\.appEnvironment, AppEnvironment())
        .environment(\.rootCoordinator, RootCoordinator())
}

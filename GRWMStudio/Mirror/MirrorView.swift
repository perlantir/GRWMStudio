import OSLog
import SwiftUI

struct MirrorView: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.rootCoordinator) private var coordinator
    @State private var viewModel = MirrorViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            DHWallpaperGradient()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                MirrorChrome.top()
                    .padding(.horizontal, 18)
                    .padding(.top, 8)

                cameraRegion
                    .padding(.horizontal, 14)
                    .padding(.top, 12)

                Spacer(minLength: 220)
            }
        }
        .preferredColorScheme(.light)
        .task {
            await viewModel.start(env: env)
        }
        .onDisappear {
            viewModel.pause()
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

    private func errorMessage(for variant: ErrorVariant) -> String {
        switch variant {
        case .license:
            "Studio Pro needs a grown-up."
        case .licenseInvalid:
            "License check needs attention."
        case .effectFail:
            "The mirror effect needs a reset."
        case .camDenied:
            "Camera access is off."
        case .micDenied:
            "Microphone access is off."
        case .photoDenied:
            "Photos access is off."
        case .recFail:
            "Recording needs a reset."
        case .saveFail:
            "Saving needs a reset."
        case .noFace:
            "Move your face into the mirror."
        case .lowStorage:
            "This phone needs more free space."
        }
    }
}

#Preview("Mirror View") {
    MirrorView()
        .environment(\.appEnvironment, AppEnvironment())
        .environment(\.rootCoordinator, RootCoordinator())
}

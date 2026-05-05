import SwiftUI
import UIKit

struct PermissionsView: View {
    @Environment(\.rootCoordinator) private var coordinator
    @Environment(\.appEnvironment) private var env
    @State private var camera: AppPermissionStatus = .notDetermined
    @State private var mic: AppPermissionStatus = .notDetermined
    @State private var photos: AppPermissionStatus = .notDetermined
    @State private var requesting: Set<PermissionKind> = []

    private enum PermissionKind: Hashable {
        case camera
        case mic
        case photos
    }

    var body: some View {
        ZStack {
            DHWallpaperGradient(top: DH.cream, bottom: DH.pinkPaper)

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, DH.Spacing.hPad)
                    .padding(.top, 4)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        heroCard
                        headline
                        permissionRows
                    }
                    .padding(.horizontal, DH.Spacing.hPad)
                    .padding(.top, 22)
                    .padding(.bottom, 18)
                }

                bottomControls
                    .padding(.horizontal, DH.Spacing.hPad)
                    .padding(.bottom, 24)
            }
        }
        .task {
            await refreshStatuses()
        }
        .preferredColorScheme(.light)
    }

    private var topBar: some View {
        HStack {
            Button {
                coordinator.showParentInfo()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(DH.pinkDeep)
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(.white)
                            .chunkyShadow(.sm(deep: DH.pink), shape: Circle())
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.string("common.back"))
            .accessibilityHint(L10n.string("common.back_hint"))

            Spacer()

            pageDots

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(DH.pinkDeep.opacity(0.25))
                .frame(width: 8, height: 8)

            Capsule()
                .fill(DH.pinkDeep)
                .frame(width: 24, height: 8)
                .shadow(color: DH.ink, radius: 0, x: 0, y: 2)

            Circle()
                .fill(DH.pinkDeep.opacity(0.25))
                .frame(width: 8, height: 8)
        }
        .accessibilityHidden(true)
    }

    private var heroCard: some View {
        DHCard(bg: DH.pink, deep: DH.pinkDeep, cornerRadius: DH.Radius.bigCard, padding: 0) {
            ZStack {
                RadialGradient(
                    colors: [.white.opacity(0.45), .clear],
                    center: UnitPoint(x: 0.30, y: 0.20),
                    startRadius: 0,
                    endRadius: 180
                )

                RadialGradient(
                    colors: [DH.butter.opacity(0.45), .clear],
                    center: UnitPoint(x: 0.75, y: 0.70),
                    startRadius: 0,
                    endRadius: 150
                )

                CameraIllustration()
                    .frame(width: 176, height: 154)
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: DH.Radius.bigCard))
        }
    }

    private var headline: some View {
        VStack(spacing: 10) {
            Text("onboarding.permissions.title")
                .font(DH.font(.display3))
                .tracking(DH.tracking(.display3))
                .foregroundStyle(DH.pinkDeep)
                .multilineTextAlignment(.center)

            Text("onboarding.permissions.subtitle")
                .font(DH.font(.body))
                .foregroundStyle(DH.ink.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity)
    }

    private var permissionRows: some View {
        VStack(spacing: 10) {
            PermRow(
                title: L10n.string("onboarding.permissions.camera.title"),
                description: L10n.string("onboarding.permissions.camera.description"),
                iconSystemName: "camera.fill",
                iconBackground: DH.pink,
                iconDeep: DH.pinkDeep,
                status: camera,
                isRequesting: requesting.contains(.camera)
            ) {
                Task { await request(.camera) }
            }

            PermRow(
                title: L10n.string("onboarding.permissions.microphone.title"),
                description: L10n.string("onboarding.permissions.microphone.description"),
                iconSystemName: "mic.fill",
                iconBackground: DH.lavender,
                iconDeep: DH.lavenderDeep,
                status: mic,
                isRequesting: requesting.contains(.mic)
            ) {
                Task { await request(.mic) }
            }

            PermRow(
                title: L10n.string("onboarding.permissions.photos.title"),
                description: L10n.string("onboarding.permissions.photos.description"),
                iconSystemName: "photo.fill",
                iconBackground: DH.butter,
                iconDeep: DH.butterDeep,
                iconForeground: DH.ink,
                status: photos,
                isRequesting: requesting.contains(.photos)
            ) {
                Task { await request(.photos) }
            }
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 10) {
            if camera == .denied || mic == .denied || camera == .restricted || mic == .restricted {
                Button {
                    openSettings()
                } label: {
                    Text("onboarding.permissions.open_settings")
                        .font(DH.font(.caption))
                        .foregroundStyle(DH.pinkDeep.opacity(0.75))
                        .underline()
                        .multilineTextAlignment(.center)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.string("common.open_settings"))
            }

            DHButton(
                title: L10n.string("common.continue"),
                kind: .primary,
                size: .xl,
                trailingIcon: AnyView(Image(systemName: "arrow.right")),
                isFullWidth: true
            ) {
                if canContinue {
                    coordinator.completeOnboarding(env: env)
                } else if camera == .denied || camera == .restricted {
                    coordinator.showPermissionsDenied()
                    coordinator.presentError(.camDenied)
                }
            }
            .opacity(canContinue ? 1 : 0.5)
            .disabled(!canContinue)
            .accessibilityLabel(L10n.string("common.continue"))
        }
    }

    @MainActor
    private func refreshStatuses() async {
        camera = await env.permissions.cameraStatus()
        mic = await env.permissions.micStatus()
        photos = await env.permissions.photosAddStatus()
    }

    @MainActor
    private func request(_ kind: PermissionKind) async {
        requesting.insert(kind)
        defer { requesting.remove(kind) }

        switch kind {
        case .camera:
            camera = await env.permissions.requestCamera()
            if camera == .denied || camera == .restricted {
                coordinator.showPermissionsDenied()
                coordinator.presentError(.camDenied)
            }
        case .mic:
            mic = await env.permissions.requestMic()
        case .photos:
            photos = await env.permissions.requestPhotosAdd()
        }
    }

    private var canContinue: Bool {
        camera == .granted && mic == .granted
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(url)
    }
}

private struct CameraIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(.white)
                .frame(width: 160, height: 130)
                .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 6)
                .overlay(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(DH.pinkLight.opacity(0.6))
                        .frame(height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }

            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .frame(width: 64, height: 24)
                .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 4)
                .offset(y: -72)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [DH.pinkLight, DH.pinkDeep],
                        center: UnitPoint(x: 0.35, y: 0.30),
                        startRadius: 0,
                        endRadius: 54
                    )
                )
                .frame(width: 96, height: 96)
                .overlay {
                    Circle().stroke(.white, lineWidth: 4)
                    Circle()
                        .fill(.white.opacity(0.7))
                        .frame(width: 18, height: 18)
                        .offset(x: -18, y: -22)
                }
                .shadow(color: DH.ink.opacity(0.2), radius: 0, x: 0, y: 5)

            Circle()
                .fill(DH.butter)
                .frame(width: 14, height: 14)
                .shadow(color: DH.butterDeep, radius: 0, x: 0, y: 2)
                .offset(x: 58, y: -48)

            StickerSparkle(size: 28, fill: .white)
                .rotationEffect(.degrees(15))
                .offset(x: 78, y: -78)

            StickerSparkle(size: 22, fill: DH.butter)
                .offset(x: -82, y: 62)
        }
        .accessibilityHidden(true)
    }
}

#Preview("Permissions") {
    PermissionsView()
        .environment(\.rootCoordinator, RootCoordinator())
        .environment(\.appEnvironment, AppEnvironment())
}

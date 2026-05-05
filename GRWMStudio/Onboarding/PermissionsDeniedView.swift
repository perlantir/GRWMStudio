import SwiftUI
import UIKit

struct PermissionsDeniedView: View {
    @Environment(\.rootCoordinator) private var coordinator
    @Environment(\.appEnvironment) private var env
    @Environment(\.scenePhase) private var scenePhase
    @State private var isChecking = false

    var body: some View {
        ZStack {
            DHWallpaperGradient(top: DH.pinkPaper, bottom: DH.cream)

            VStack(spacing: 28) {
                Spacer(minLength: 28)

                sadCamera

                VStack(spacing: 12) {
                    Text("onboarding.permissions_denied.title")
                        .font(DH.font(.display3))
                        .tracking(DH.tracking(.display3))
                        .foregroundStyle(DH.pinkDeep)
                        .multilineTextAlignment(.center)

                    Text(
                        "onboarding.permissions_denied.subtitle"
                    )
                        .font(DH.font(.body))
                        .foregroundStyle(DH.pinkDeep.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                }

                Spacer()

                VStack(spacing: 12) {
                    DHButton(
                        title: L10n.string("common.open_settings"),
                        kind: .primary,
                        size: .xl,
                        trailingIcon: AnyView(Image(systemName: "gearshape.fill")),
                        isFullWidth: true
                    ) {
                        openSettings()
                    }
                    .accessibilityLabel(L10n.string("common.open_settings"))

                    DHButton(
                        title: isChecking ? L10n.string("common.checking") : L10n.string("common.try_again"),
                        kind: .ghost,
                        size: .xl,
                        isFullWidth: true
                    ) {
                        Task { await retryCamera() }
                    }
                    .disabled(isChecking)
                    .accessibilityLabel(L10n.string("common.try_again"))
                }
                .padding(.horizontal, DH.Spacing.hPad)
                .padding(.bottom, 24)
            }
        }
        .task {
            await advanceIfCameraRecovered()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else {
                return
            }

            Task { await advanceIfCameraRecovered() }
        }
        .preferredColorScheme(.light)
    }

    private var sadCamera: some View {
        ZStack {
            Circle()
                .fill(DH.pinkPaper)
                .frame(width: 180, height: 180)
                .chunkyShadow(.md(deep: DH.pink), shape: Circle())

            Image(systemName: "camera.fill")
                .font(.system(size: 62, weight: .bold))
                .foregroundStyle(DH.pinkDeep)

            Image(systemName: "face.smiling")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(DH.recRed)
                .rotationEffect(.degrees(180))
                .offset(y: 58)

            StickerSparkle(size: 22, fill: DH.butter)
                .offset(x: 84, y: -72)

            StickerSparkle(size: 18, fill: .white, stroke: DH.pinkLight)
                .offset(x: -78, y: 66)
        }
        .accessibilityHidden(true)
    }

    @MainActor
    private func retryCamera() async {
        isChecking = true
        defer { isChecking = false }

        let status = await env.permissions.requestCamera()
        guard status == .granted else {
            return
        }

        await routeAfterCameraGrant()
    }

    @MainActor
    private func advanceIfCameraRecovered() async {
        let status = await env.permissions.cameraStatus()
        guard status == .granted else {
            return
        }

        await routeAfterCameraGrant()
    }

    @MainActor
    private func routeAfterCameraGrant() async {
        coordinator.dismissError()
        let mic = await env.permissions.micStatus()
        if mic == .granted {
            coordinator.completeOnboarding(env: env)
        } else {
            coordinator.showPermissions()
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(url)
    }
}

#Preview("Permissions Denied") {
    PermissionsDeniedView()
        .environment(\.rootCoordinator, RootCoordinator())
        .environment(\.appEnvironment, AppEnvironment())
}

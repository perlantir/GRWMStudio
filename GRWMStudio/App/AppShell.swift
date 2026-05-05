import SwiftUI

struct AppShell: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.rootCoordinator) private var coordinator
    @State private var selected: DHTab = .mirror
    @State private var mirrorViewModel = MirrorViewModel()

    private let lastTabKey = "dh_last_tab"

    var body: some View {
        selectedTabContent
            .overlay(alignment: .bottom) {
                if selected == .mirror {
                    mirrorTabBar
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if selected != .mirror {
                    nonMirrorTabBar
                }
            }
        .preferredColorScheme(.light)
        .environment(\.appShellSelector, selectTab)
        .onAppear(perform: restoreSelectedTab)
        .onChange(of: selected) { _, newValue in
            guard newValue != .fab else {
                return
            }
            UserDefaults.standard.set(newValue.rawValue, forKey: lastTabKey)
        }
        .onReceive(NotificationCenter.default.publisher(for: .pickDifferentLook)) { _ in
            selected = .looks
        }
        .onReceive(NotificationCenter.default.publisher(for: .lockerEnterDeleteMode)) { _ in
            selected = .locker
        }
    }

    @ViewBuilder
    private var selectedTabContent: some View {
        switch selected {
        case .mirror, .fab:
            MirrorView(viewModel: mirrorViewModel) {
                selected = .looks
            }
        case .looks:
            LooksLibraryView(
                onTryLookFromGrid: { look in
                    Task { @MainActor in
                        guard routeToPaywallIfNeeded(for: look) else {
                            selected = .mirror
                            return
                        }
                        await mirrorViewModel.selectLook(look)
                        selected = .mirror
                    }
                }
            )
        case .feed:
            DHFeedView(
                onTryLook: { look in
                    Task { @MainActor in
                        guard routeToPaywallIfNeeded(for: look) else {
                            selected = .mirror
                            return
                        }
                        await mirrorViewModel.selectLook(look)
                        selected = .mirror
                    }
                }
            )
        case .locker:
            LockerView()
        }
    }

    private var mirrorTabBar: some View {
        ZStack {
            DHTabBar(selected: $selected, onFABTap: routeToFreshMirror, showsDefaultFAB: false)

            if mirrorViewModel.state == .running, !mirrorViewModel.isRecording {
                CaptureKindPicker(selection: $mirrorViewModel.selectedCaptureKind)
                    .offset(y: dynamicTypeSize.isAccessibilitySize ? -152 : -174)
            }

            CaptureFAB(
                mode: mirrorCaptureMode,
                kind: mirrorViewModel.selectedCaptureKind
            ) {
                Task { @MainActor in
                    await mirrorViewModel.captureButtonTapped()
                }
            }
            .offset(y: dynamicTypeSize.isAccessibilitySize ? -20 : -34)

            if mirrorViewModel.isRecording {
                RecordingStopChip {
                    Task { @MainActor in
                        await mirrorViewModel.captureButtonTapped()
                    }
                }
                .offset(y: dynamicTypeSize.isAccessibilitySize ? 36 : 44)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 18)
    }

    private var nonMirrorTabBar: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: dynamicTypeSize.isAccessibilitySize ? 92 : 78)
                .accessibilityHidden(true)

            DHTabBar(selected: $selected, onFABTap: routeToFreshMirror)
                .padding(.horizontal, 14)
                .padding(.bottom, 18)
        }
        .background(
            LinearGradient(
                colors: [DH.cream.opacity(0), DH.cream.opacity(0.92), DH.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    private var mirrorCaptureMode: CaptureMode {
        guard mirrorViewModel.state == .running else {
            return .disabled
        }
        return mirrorViewModel.activeCaptureMode
    }

    private func placeholder(_ title: String) -> some View {
        ZStack {
            DHWallpaperGradient()

            Text(title)
                .font(DH.font(.headline))
                .tracking(DH.tracking(.headline))
                .foregroundStyle(DH.pinkDeep)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            #if DEBUG
            VStack {
                HStack {
                    Spacer()
                    DHButton(title: L10n.string("settings.developer.reset_onboarding"), kind: .ghost, size: .sm) {
                        env.onboarding.reset()
                        coordinator.route = .onboardingSplash
                    }
                    .accessibilityLabel(L10n.string("settings.developer.reset_onboarding"))
                }
                .padding(.top, 72)
                .padding(.trailing, 18)

                Spacer()
            }
            #endif
        }
        .ignoresSafeArea()
    }

    private func restoreSelectedTab() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-GRWMDebugStartMirror") {
            selected = .mirror
            return
        }

        if ProcessInfo.processInfo.arguments.contains("-GRWMDebugStartLooks") {
            selected = .looks
            return
        }

        if ProcessInfo.processInfo.arguments.contains("-GRWMDebugStartFeed") {
            selected = .feed
            return
        }

        if ProcessInfo.processInfo.arguments.contains("-GRWMDebugStartLocker") {
            selected = .locker
            return
        }

        guard !ProcessInfo.processInfo.arguments.contains("-GRWMDebugAppShell") else {
            UserDefaults.standard.removeObject(forKey: lastTabKey)
            selected = .mirror
            return
        }
        #endif

        guard
            let raw = UserDefaults.standard.string(forKey: lastTabKey),
            let tab = DHTab(rawValue: raw),
            tab != .fab
        else {
            return
        }

        selected = tab
    }

    private func routeToFreshMirror() {
        env.mirrorCreateNewIntent = true
        selected = .mirror
    }

    private func selectTab(_ tab: DHTab) {
        guard tab != .fab else {
            routeToFreshMirror()
            return
        }
        selected = tab
    }

    private func routeToPaywallIfNeeded(for look: LookPreset) -> Bool {
        guard look.isPro, !ProEntitlementsHolder.shared.entitlements.isPro else {
            return true
        }

        coordinator.startParentGate(intent: .paywall(source: .proShade))
        return false
    }
}

private struct CaptureKindPicker: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .caption) private var pillHeight = 30
    @Binding var selection: CaptureKind

    var body: some View {
        HStack(spacing: 4) {
            ForEach(CaptureKind.allCases) { kind in
                Button {
                    withAnimation(DHAnim.respecting(.quickPop, reduceMotion: reduceMotion)) {
                        selection = kind
                    }
                    DHHaptics.light()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: kind.systemName)
                            .font(.system(size: 12, weight: .heavy))

                        Text(kind.label)
                            .font(DH.font(.microLabel))
                            .tracking(DH.tracking(.microLabel))
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 1 : 2)
                            .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.65 : 0.85)
                    }
                    .foregroundStyle(selection == kind ? .white : DH.pinkDeep)
                    .padding(.horizontal, 10)
                    .frame(height: min(pillHeight, dynamicTypeSize.isAccessibilitySize ? 32 : 30))
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                    .background {
                        Capsule()
                            .fill(selection == kind ? DH.pinkDeep : .white)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.format("capture.kind.accessibility_label", kind.label))
                .accessibilityValue(selection == kind ? L10n.string("common.selected") : L10n.string("common.not_selected"))
                .accessibilityHint(
                    kind == .photo
                        ? L10n.string("capture.kind.photo_hint")
                        : L10n.string("capture.kind.video_hint")
                )
                .accessibilityIdentifier("capture-mode-\(kind.rawValue)")
                .accessibilityAddTraits(selection == kind ? [.isSelected] : [])
            }
        }
        .padding(4)
        .background {
            Capsule()
                .fill(DH.cream.opacity(0.96))
                .chunkyShadow(.sm(deep: DH.pinkDeep), shape: Capsule())
        }
        .accessibilityIdentifier("capture-mode-picker")
    }
}

#Preview("App Shell") {
    AppShell()
        .environment(\.appEnvironment, AppEnvironment())
}

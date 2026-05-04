import SwiftUI

struct AppShell: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.rootCoordinator) private var coordinator
    @State private var selected: DHTab = .mirror
    @State private var mirrorViewModel = MirrorViewModel()

    private let lastTabKey = "dh_last_tab"

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selected) {
                MirrorView(viewModel: mirrorViewModel) {
                    selected = .looks
                }
                    .tag(DHTab.mirror)

                placeholder("Looks Library - wired in GRWM-500")
                    .tag(DHTab.looks)

                Color.clear
                    .tag(DHTab.fab)

                placeholder("Feed - wired in GRWM-602")
                    .tag(DHTab.feed)

                placeholder("Locker - wired in GRWM-503")
                    .tag(DHTab.locker)
            }
            .toolbar(.hidden, for: .tabBar)

            tabBar
        }
        .preferredColorScheme(.light)
        .onAppear(perform: restoreSelectedTab)
        .onChange(of: selected) { _, newValue in
            guard newValue != .fab else {
                return
            }

            UserDefaults.standard.set(newValue.rawValue, forKey: lastTabKey)
        }
    }

    @ViewBuilder
    private var tabBar: some View {
        if selected == .mirror {
            ZStack {
                DHTabBar(selected: $selected, onFABTap: routeToFreshMirror, showsDefaultFAB: false)

                if mirrorViewModel.state == .running, !mirrorViewModel.isRecording {
                    CaptureKindPicker(selection: $mirrorViewModel.selectedCaptureKind)
                        .offset(y: -174)
                }

                CaptureFAB(
                    mode: mirrorCaptureMode,
                    kind: mirrorViewModel.selectedCaptureKind
                ) {
                    Task { @MainActor in
                        await mirrorViewModel.captureButtonTapped()
                    }
                }
                .offset(y: -34)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 18)
        } else {
            DHTabBar(selected: $selected, onFABTap: routeToFreshMirror)
                .padding(.horizontal, 14)
                .padding(.bottom, 18)
        }
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
                    DHButton(title: "Reset Onboarding", kind: .ghost, size: .sm) {
                        env.onboarding.reset()
                        coordinator.route = .onboardingSplash
                    }
                    .accessibilityLabel("Reset onboarding")
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
}

private struct CaptureKindPicker: View {
    @Binding var selection: CaptureKind

    var body: some View {
        HStack(spacing: 4) {
            ForEach(CaptureKind.allCases) { kind in
                Button {
                    withAnimation(.bouncy(duration: 0.22)) {
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
                    }
                    .foregroundStyle(selection == kind ? .white : DH.pinkDeep)
                    .padding(.horizontal, 10)
                    .frame(height: 30)
                    .background {
                        Capsule()
                            .fill(selection == kind ? DH.pinkDeep : .white)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(kind.label) capture mode")
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

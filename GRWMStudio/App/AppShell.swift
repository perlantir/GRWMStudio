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
                MirrorView(viewModel: mirrorViewModel)
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

                CaptureFAB(
                    mode: mirrorCaptureMode,
                    onTap: mirrorViewModel.onCaptureTap,
                    onLongPressBegan: mirrorViewModel.onCaptureLongPressBegan
                ) { duration in
                    mirrorViewModel.onCaptureLongPressEnded(duration: duration)
                }
                .accessibilityIdentifier("capture-fab")
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

#Preview("App Shell") {
    AppShell()
        .environment(\.appEnvironment, AppEnvironment())
}

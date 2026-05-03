import SwiftUI

struct AppShell: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.rootCoordinator) private var coordinator
    @State private var selected: DHTab = .mirror

    private let lastTabKey = "dh_last_tab"

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selected) {
                placeholder("Mirror Tab - wired in GRWM-300")
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

            DHTabBar(selected: $selected) {
                env.mirrorCreateNewIntent = true
                selected = .mirror
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 18)

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
                .padding(.top, 12)
                .padding(.trailing, 18)

                Spacer()
            }
            #endif
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

    private func placeholder(_ title: String) -> some View {
        ZStack {
            DHWallpaperGradient()

            Text(title)
                .font(DH.font(.headline))
                .tracking(DH.tracking(.headline))
                .foregroundStyle(DH.pinkDeep)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
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
}

#Preview("App Shell") {
    AppShell()
        .environment(\.appEnvironment, AppEnvironment())
}

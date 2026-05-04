import SwiftData
import SwiftUI
import UIKit

struct AppShell: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.rootCoordinator) private var coordinator
    @State private var selected: DHTab = .mirror
    @State private var mirrorViewModel = MirrorViewModel()

    private let lastTabKey = "dh_last_tab"

    var body: some View {
        ZStack(alignment: .bottom) {
            selectedTabContent

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
    private var selectedTabContent: some View {
        switch selected {
        case .mirror, .fab:
            MirrorView(viewModel: mirrorViewModel) {
                selected = .looks
            }
        case .looks:
            placeholder("Looks Library - wired in GRWM-500")
        case .feed:
            placeholder("Feed - wired in GRWM-602")
        case .locker:
            LockerView {
                selected = .mirror
            }
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

                if mirrorViewModel.isRecording {
                    RecordingStopChip {
                        Task { @MainActor in
                            await mirrorViewModel.captureButtonTapped()
                        }
                    }
                    .offset(y: 44)
                    .transition(.scale.combined(with: .opacity))
                }
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

private struct LockerView: View {
    @Query(sort: \SavedCapture.createdAt, order: .reverse) private var captures: [SavedCapture]
    let onOpenMirror: () -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 3
    )

    var body: some View {
        ZStack(alignment: .top) {
            DHWallpaperGradient()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    if captures.isEmpty {
                        LockerEmptyState(onOpenMirror: onOpenMirror)
                            .padding(.top, 48)
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(captures) { capture in
                                LockerCaptureCard(capture: capture)
                            }
                        }
                        .accessibilityIdentifier("locker-grid")
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 146)
            }
        }
        .accessibilityIdentifier("locker-view")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("YOUR LOCKER")
                .font(DH.font(.microLabel))
                .tracking(DH.tracking(.microLabel))
                .foregroundStyle(DH.ink.opacity(0.58))

            HStack(alignment: .firstTextBaseline) {
                Text("Saved Looks")
                    .font(DH.font(.display3))
                    .tracking(DH.tracking(.display3))
                    .foregroundStyle(DH.pinkDeep)

                Spacer()

                Text("\(captures.count)")
                    .font(DH.font(.buttonLarge))
                    .tracking(DH.tracking(.buttonLarge))
                    .foregroundStyle(.white)
                    .frame(minWidth: 44, minHeight: 34)
                    .background {
                        Capsule()
                            .fill(DH.pink)
                            .chunkyShadow(.sm(deep: DH.pinkDeep), shape: Capsule())
                    }
                    .accessibilityLabel("\(captures.count) saved looks")
            }
        }
        .padding(.top, 58)
        .accessibilityElement(children: .combine)
    }
}

private struct LockerEmptyState: View {
    let onOpenMirror: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                RoundedRectangle(cornerRadius: DH.Radius.bigCard)
                    .fill(.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: DH.Radius.bigCard)
                            .strokeBorder(DH.pink, style: StrokeStyle(lineWidth: 4, dash: [8, 6]))
                    }
                    .chunkyShadow(.md(deep: DH.pinkLight), shape: RoundedRectangle(cornerRadius: DH.Radius.bigCard))

                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 74, weight: .black))
                    .foregroundStyle(DH.pinkDeep)
            }
            .frame(width: 180, height: 180)

            VStack(spacing: 8) {
                Text("Your locker is empty")
                    .font(DH.font(.headline))
                    .tracking(DH.tracking(.headline))
                    .foregroundStyle(DH.pinkDeep)
                    .multilineTextAlignment(.center)

                Text("Save a photo or video from the mirror and it will show up here.")
                    .font(DH.font(.body))
                    .tracking(DH.tracking(.body))
                    .foregroundStyle(DH.ink.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
            }

            DHButton(
                title: "Open the Mirror",
                kind: .primary,
                size: .xl,
                leadingIcon: AnyView(Image(systemName: "camera.fill")),
                isFullWidth: true,
                action: onOpenMirror
            )
        }
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("locker-empty-state")
    }
}

private struct LockerCaptureCard: View {
    let capture: SavedCapture

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LockerThumbnail(capture: capture)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: DH.Radius.tile))
                .overlay(alignment: .topTrailing) {
                    if capture.kind == .video {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(DH.ink.opacity(0.62)))
                            .padding(6)
                    }
                }

            Text(capture.name)
                .font(DH.font(.microLabel))
                .tracking(DH.tracking(.microLabel))
                .foregroundStyle(DH.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: DH.Radius.card)
                .fill(.white)
                .chunkyShadow(.sm(deep: DH.pink), shape: RoundedRectangle(cornerRadius: DH.Radius.card))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(capture.name), \(capture.kind.rawValue)")
        .accessibilityIdentifier("locker-card-\(capture.id.uuidString)")
    }
}

private struct LockerThumbnail: View {
    let capture: SavedCapture

    var body: some View {
        ZStack {
            DH.pinkPaper

            if capture.kind == .photo,
               let image = UIImage(contentsOfFile: captureURL.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                VStack(spacing: 8) {
                    Image(systemName: capture.kind == .video ? "video.fill" : "photo.fill")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(DH.pinkDeep)

                    Text(capture.kind == .video ? "Video" : "Photo")
                        .font(DH.font(.microLabel))
                        .tracking(DH.tracking(.microLabel))
                        .foregroundStyle(DH.pinkDeep)
                }
            }
        }
    }

    private var captureURL: URL {
        URL.documentsCapturesURL.appendingPathComponent(capture.mediaPath)
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

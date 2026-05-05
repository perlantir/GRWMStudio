import SwiftData
import SwiftUI

struct LockerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: LockerViewModel?
    @State private var selectedCapture: SavedCapture?
    @State private var shareCapture: SavedCapture?
    @State private var pendingShareCapture: SavedCapture?
    @State private var showAvatarEditor = false
    @State private var showSettings = false
    @State var deleteMode = false

    private var debugFreezeLoading: Bool {
        DebugRuntimeFlags.contains("-GRWMDebugFreezeLockerLoading")
    }

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                LinearGradient(colors: [DH.pink, DH.pinkLight], startPoint: .top, endPoint: .bottom)
                    .frame(height: 520)
                DH.cream
            }
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if debugFreezeLoading {
                        lockerLoadingState
                            .padding(.horizontal, 18)
                            .padding(.top, 58)
                    } else if let viewModel {
                        LockerProfileHeroView(
                            viewModel: viewModel,
                            onEditAvatar: { showAvatarEditor = true },
                            onShowSettings: { showSettings = true }
                        )
                        .padding(.horizontal, 18)
                        .padding(.top, 58)

                        lockerBody(viewModel)
                            .padding(.horizontal, 12)
                    } else {
                        lockerLoadingState
                            .padding(.horizontal, 18)
                            .padding(.top, 58)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .task {
            guard !debugFreezeLoading else {
                return
            }
            if viewModel == nil {
                let newViewModel = LockerViewModel(modelContext)
                try? await Task.sleep(
                    for: DebugRuntimeFlags.delay(
                        .milliseconds(180),
                        slowFlag: "-GRWMDebugSlowLoadingStates"
                    )
                )
                newViewModel.reload()
                viewModel = newViewModel
                return
            }
            viewModel?.reload()
        }
        .onReceive(NotificationCenter.default.publisher(for: .profileChanged)) { _ in
            viewModel?.reload()
        }
        .onReceive(NotificationCenter.default.publisher(for: .lockerEnterDeleteMode)) { _ in
            deleteMode = true
        }
        .onChange(of: selectedCapture) { _, newValue in
            guard newValue == nil, let pendingShareCapture else {
                return
            }

            shareCapture = pendingShareCapture
            self.pendingShareCapture = nil
        }
        .fullScreenCover(item: $selectedCapture) { capture in
            if let viewModel {
                LockerDetailView(
                    capture: capture,
                    url: viewModel.captureURL(capture),
                    onShare: {
                        pendingShareCapture = capture
                        selectedCapture = nil
                    },
                    onDelete: {
                        viewModel.delete(capture)
                        selectedCapture = nil
                    },
                    onDismiss: {
                        selectedCapture = nil
                    }
                )
            }
        }
        .fullScreenCover(item: $shareCapture) { capture in
            if let viewModel {
                SaveShareView(
                    capture: capture,
                    captureURL: viewModel.captureURL(capture),
                    onDone: {
                        shareCapture = nil
                    }
                )
            }
        }
        .sheet(isPresented: $showAvatarEditor, onDismiss: {
            viewModel?.reload()
        }, content: {
            if let record = viewModel?.profile {
                AvatarEditorView(record: record) {
                    viewModel?.reload()
                }
            }
        })
        .fullScreenCover(
            isPresented: $showSettings,
            onDismiss: {
                viewModel?.reload()
            },
            content: {
                DHSettingsView()
            }
        )
        .accessibilityIdentifier("locker-view")
    }

    private func lockerBody(_ viewModel: LockerViewModel) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            recentLooks(viewModel)

            header(viewModel)

            if deleteMode {
                deleteModeBanner
            }

            if viewModel.captures.isEmpty {
                LockerEmptyView()
                    .padding(.top, 12)
            } else {
                if viewModel.isAtLimit {
                    LockerAtLimitBanner()
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.captures) { capture in
                        LockerCardView(
                            capture: capture,
                            url: viewModel.captureURL(capture),
                            deleteMode: deleteMode,
                            onTap: {
                                selectedCapture = capture
                            },
                            onDelete: {
                                viewModel.delete(capture)
                            }
                        )
                    }
                }
                .accessibilityIdentifier("locker-grid")
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 28)
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(DH.cream)
                .shadow(color: DH.pinkLight.opacity(0.34), radius: 18, x: 0, y: -2)
        }
    }

    private func recentLooks(_ viewModel: LockerViewModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("locker.recent.title")
                    .font(DH.font(.headline))
                    .tracking(DH.tracking(.headline))
                    .foregroundStyle(DH.ink)

                Spacer(minLength: 0)

                Text(L10n.string(viewModel.captures.isEmpty ? "locker.recent.empty_label" : "locker.recent.latest_label"))
                    .font(DH.font(.caption))
                    .tracking(DH.tracking(.caption))
                    .foregroundStyle(DH.ink.opacity(0.55))
            }

            if viewModel.captures.isEmpty {
                Text("locker.recent.empty_cta")
                    .font(DH.font(.bodyEmphasis))
                    .tracking(DH.tracking(.bodyEmphasis))
                    .foregroundStyle(DH.pinkDeep)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.white, in: Capsule())
                    .chunkyShadow(.sm(deep: DH.pinkLight), shape: Capsule())
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(viewModel.captures.prefix(3))) { capture in
                            LockerRecentTile(
                                capture: capture,
                                url: viewModel.captureURL(capture)
                            ) {
                                selectedCapture = capture
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private func header(_ viewModel: LockerViewModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("locker.eyebrow")
                .font(DH.font(.microLabel))
                .tracking(DH.tracking(.microLabel))
                .foregroundStyle(DH.ink.opacity(0.58))

            HStack(alignment: .firstTextBaseline) {
                Text("locker.title")
                    .font(DH.font(.display3))
                    .tracking(DH.tracking(.display3))
                    .foregroundStyle(DH.pinkDeep)

                Spacer(minLength: 0)

                Text("\(viewModel.captures.count)")
                    .font(DH.font(.buttonLarge))
                    .tracking(DH.tracking(.buttonLarge))
                    .foregroundStyle(.white)
                    .frame(minWidth: 44, minHeight: 34)
                    .background {
                        Capsule()
                            .fill(DH.pink)
                            .chunkyShadow(.sm(deep: DH.pinkDeep), shape: Capsule())
                    }
                    .accessibilityLabel(Text(verbatim: L10n.plural("locker.count", viewModel.captures.count)))
            }
        }
    }

}

private struct LockerRecentTile: View {
    let capture: SavedCapture
    let url: URL
    let action: () -> Void

    @State private var thumbnail: UIImage?

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .frame(width: 108, height: 118)
                        .overlay {
                            Group {
                                if let thumbnail {
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    DHWallpaperGradient(top: DH.pinkLight, bottom: DH.pinkPaper)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }

                    if capture.kind == .video {
                        Image(systemName: "play.fill")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(DH.pinkDeep, in: Circle())
                            .padding(8)
                    }
                }
                .chunkyShadow(.sm(deep: DH.pinkLight), shape: RoundedRectangle(cornerRadius: 20))

                Text(capture.name)
                    .font(DH.font(.caption))
                    .tracking(DH.tracking(.caption))
                    .foregroundStyle(DH.ink)
                    .lineLimit(1)
                    .frame(width: 108, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .task {
            thumbnail = await ThumbnailLoader.shared.load(url: url, kind: capture.kind)
        }
    }
}

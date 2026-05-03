import AVKit
import OSLog
import SwiftUI
import UIKit

struct PreviewPlaceholderView: View {
    let asset: CapturedAsset
    let onClose: () -> Void
    @State private var saveState: SaveState = .idle
    @State private var activeSaver: PhotoLibrarySaver?

    var body: some View {
        GeometryReader { proxy in
            let metrics = PreviewLayoutMetrics(size: proxy.size, safeAreaInsets: proxy.safeAreaInsets)

            ZStack {
                DHWallpaperGradient()
                    .ignoresSafeArea()

                VStack(spacing: metrics.verticalSpacing) {
                    topBar
                        .frame(height: metrics.topBarHeight)
                        .zIndex(2)

                    mediaCard
                        .frame(width: metrics.mediaWidth, height: metrics.mediaHeight)
                        .zIndex(1)

                    bottomControls
                        .frame(height: metrics.bottomControlsHeight)
                        .zIndex(2)
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                .padding(.top, metrics.topPadding)
                .padding(.bottom, metrics.bottomPadding)
            }
        }
        .preferredColorScheme(.light)
        .accessibilityIdentifier("preview-placeholder")
    }

    private var topBar: some View {
        HStack {
            Button {
                onClose()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .heavy))

                    Text("Mirror")
                        .font(DH.font(.buttonSmall))
                        .tracking(DH.tracking(.buttonSmall))
                }
                .foregroundStyle(DH.pinkDeep)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background {
                    Capsule()
                        .fill(.white)
                        .chunkyShadow(.sm(deep: DH.pinkDeep), shape: Capsule())
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back to mirror")

            Spacer()
        }
        .padding(.horizontal, 18)
    }

    private var mediaCard: some View {
        assetView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DH.pinkPaper)
            .clipShape(RoundedRectangle(cornerRadius: DH.Radius.viewportInner))
            .overlay {
                RoundedRectangle(cornerRadius: DH.Radius.viewportInner)
                    .strokeBorder(.white, lineWidth: 6)
            }
            .chunkyShadow(.lg(deep: DH.pinkDeep), shape: RoundedRectangle(cornerRadius: DH.Radius.viewportInner))
    }

    private var bottomControls: some View {
        VStack(spacing: 12) {
            Text(statusTitle)
                .font(DH.font(.caption))
                .tracking(DH.tracking(.caption))
                .foregroundStyle(statusColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(.white.opacity(0.92)))

            HStack(spacing: 12) {
                PreviewActionButton(
                    title: saveButtonTitle,
                    kind: .primary,
                    systemImage: "square.and.arrow.down"
                ) {
                    Task { @MainActor in
                        await saveToPhotos()
                    }
                }
                .disabled(saveState == .saving)

                PreviewActionButton(
                    title: "Done",
                    kind: .white,
                    action: onClose
                )
            }
        }
        .padding(.horizontal, 18)
    }

    @ViewBuilder
    private var assetView: some View {
        switch asset {
        case .photo(let image):
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Captured photo preview")

        case .video(let url):
            VideoPreviewPlayer(url: url)
                .accessibilityIdentifier("captured-video-preview")
        }
    }

    private var previewTitle: String {
        switch asset {
        case .photo:
            "Photo Preview"
        case .video:
            "Video Preview"
        }
    }

    private var statusTitle: String {
        switch saveState {
        case .idle:
            previewTitle
        case .saving:
            "Saving..."
        case .saved:
            "Saved to Photos"
        case .failed:
            "Saving needs a reset"
        }
    }

    private var statusColor: Color {
        switch saveState {
        case .failed:
            DH.recRedDeep
        default:
            DH.pinkDeep
        }
    }

    private var saveButtonTitle: String {
        switch saveState {
        case .saving:
            "Saving"
        case .saved:
            "Saved"
        default:
            "Save"
        }
    }

    @MainActor
    private func saveToPhotos() async {
        guard saveState != .saving else {
            return
        }

        saveState = .saving
        let saver = PhotoLibrarySaver()
        activeSaver = saver
        defer { activeSaver = nil }

        do {
            try await saver.save(asset: asset)
            saveState = .saved
        } catch {
            Logger.capture.error("Preview save failed: \(error.localizedDescription, privacy: .public)")
            saveState = .failed
        }
    }
}

private struct PreviewLayoutMetrics {
    let mediaWidth: CGFloat
    let mediaHeight: CGFloat
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    let topBarHeight: CGFloat = 52
    let bottomControlsHeight: CGFloat = 92
    let verticalSpacing: CGFloat = 12

    init(size: CGSize, safeAreaInsets: EdgeInsets) {
        let horizontalPadding: CGFloat = 18
        mediaWidth = max(280, size.width - horizontalPadding * 2)
        topPadding = safeAreaInsets.top + 8
        bottomPadding = max(safeAreaInsets.bottom, 12) + 12

        let reservedHeight = topPadding
            + topBarHeight
            + bottomControlsHeight
            + bottomPadding
            + verticalSpacing * 2
        mediaHeight = max(280, size.height - reservedHeight)
    }
}

private struct VideoPreviewPlayer: View {
    let url: URL
    @State private var player: AVPlayer?
    @State private var isPlaying = false

    var body: some View {
        ZStack {
            DH.pinkPaper

            if let player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.seek(to: .zero)
                        player.play()
                        isPlaying = true
                    }

                playbackButton
            } else {
                playbackIcon(systemName: "play.fill")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            togglePlayback()
        }
        .onAppear {
            guard player == nil else {
                return
            }
            player = AVPlayer(url: url)
        }
        .onDisappear {
            player?.pause()
            player = nil
            isPlaying = false
        }
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { _ in
            isPlaying = false
        }
    }

    private var playbackButton: some View {
        Button {
            togglePlayback()
        } label: {
            playbackIcon(systemName: isPlaying ? "pause.fill" : "play.fill")
                .opacity(isPlaying ? 0.82 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isPlaying ? "Pause video preview" : "Play video preview")
    }

    private func playbackIcon(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 34, weight: .heavy))
            .foregroundStyle(.white)
            .frame(width: 74, height: 74)
            .background(Circle().fill(DH.pinkDeep.opacity(0.92)))
            .overlay(Circle().strokeBorder(.white, lineWidth: 4))
            .shadow(color: DH.pinkDeep.opacity(0.35), radius: 10, x: 0, y: 5)
    }

    private func togglePlayback() {
        guard let player else {
            return
        }

        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            if player.currentItem?.currentTime() == player.currentItem?.duration {
                player.seek(to: .zero)
            }
            player.play()
            isPlaying = true
        }
    }
}

private struct PreviewActionButton: View {
    enum Kind {
        case primary
        case white

        var background: Color {
            switch self {
            case .primary:
                DH.pink
            case .white:
                .white
            }
        }

        var foreground: Color {
            switch self {
            case .primary:
                .white
            case .white:
                DH.pinkDeep
            }
        }

        var deep: Color {
            switch self {
            case .primary:
                DH.pinkDeep
            case .white:
                DH.pink
            }
        }
    }

    let title: String
    let kind: Kind
    var systemImage: String?
    let action: () -> Void

    var body: some View {
        Button {
            DHHaptics.tapMedium()
            action()
        } label: {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .heavy))
                }

                Text(title)
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
            }
            .foregroundStyle(kind.foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background {
                ZStack {
                    Capsule()
                        .fill(kind.deep)
                        .offset(y: 4)
                    Capsule()
                        .fill(kind.background)
                }
                .shadow(color: kind.deep.opacity(0.35), radius: 14, x: 0, y: 7)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

private enum SaveState {
    case idle
    case saving
    case saved
    case failed
}

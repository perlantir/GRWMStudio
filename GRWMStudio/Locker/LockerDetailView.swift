import AVKit
import SwiftUI

struct LockerDetailView: View {
    let capture: SavedCapture
    let url: URL
    let onShare: () -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void

    @State private var confirmingDelete = false
    @State private var player = AVPlayer()

    var body: some View {
        ZStack(alignment: .top) {
            assetView
                .ignoresSafeArea()
                .background(.black)

            topBar
            footer

            if confirmingDelete {
                deleteConfirmation
            }
        }
        .onAppear {
            guard capture.kind == .video else {
                return
            }
            player.replaceCurrentItem(with: AVPlayerItem(url: url))
            player.play()
        }
        .onDisappear {
            player.pause()
        }
    }

    @ViewBuilder
    private var assetView: some View {
        if capture.kind == .video {
            VideoPlayer(player: player)
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
        } else if let image = UIImage(contentsOfFile: url.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            LinearGradient(colors: [DH.pinkLight, DH.pinkPaper], startPoint: .top, endPoint: .bottom)
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            circleButton(systemName: "xmark", action: onDismiss)
            Spacer(minLength: 0)
            circleButton(systemName: "square.and.arrow.up", action: onShare)
            circleButton(systemName: "trash") {
                confirmingDelete = true
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 60)
    }

    private var footer: some View {
        VStack {
            Spacer()
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(capture.name)
                        .font(DH.font(.headline))
                        .tracking(DH.tracking(.headline))
                        .foregroundStyle(.white)
                    Text(capture.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(DH.font(.caption))
                        .tracking(DH.tracking(.caption))
                        .foregroundStyle(.white.opacity(0.82))
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 22)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    private var deleteConfirmation: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    confirmingDelete = false
                }

            DHCard(bg: .white, deep: DH.recRedDeep, cornerRadius: DH.Radius.bigCard, padding: 20) {
                VStack(spacing: 16) {
                    Text("locker.detail.delete_title")
                        .font(DH.font(.headline))
                        .tracking(DH.tracking(.headline))
                        .foregroundStyle(DH.ink)

                    HStack(spacing: 12) {
                        DHButton(title: L10n.string("common.keep"), kind: .ghost, size: .lg, isFullWidth: true) {
                            confirmingDelete = false
                        }
                        DHButton(title: L10n.string("common.delete"), kind: .primary, size: .lg, isFullWidth: true) {
                            confirmingDelete = false
                            onDelete()
                        }
                    }
                }
            }
            .padding(.horizontal, 28)
        }
    }

    private func circleButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(DH.pinkDeep)
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.96), in: Circle())
                .chunkyShadow(.sm(deep: DH.pinkDeep), shape: Circle())
        }
        .buttonStyle(.plain)
    }
}

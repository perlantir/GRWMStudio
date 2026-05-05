import SwiftUI

struct LockerCardView: View {
    let capture: SavedCapture
    let url: URL
    let deleteMode: Bool
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var thumbnail: UIImage?

    var body: some View {
        Button(action: deleteMode ? onDelete : onTap) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .chunkyShadow(.sm(deep: DH.pink), shape: RoundedRectangle(cornerRadius: 20))

                Group {
                    if let thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                    } else {
                        LinearGradient(
                            colors: [DH.pinkLight, DH.pinkPaper, DH.cream],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: capture.kind == .video ? "video.fill" : "photo.fill")
                                    .font(.system(size: 22, weight: .heavy))
                                Text(L10n.string(capture.kind == .video ? "locker.card.video" : "locker.card.photo"))
                                    .font(DH.font(.microLabel))
                                    .tracking(DH.tracking(.microLabel))
                            }
                            .foregroundStyle(DH.pinkDeep)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(6)

                if deleteMode {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(DH.recRedDeep))
                        .padding(10)
                } else if capture.kind == .video {
                    Image(systemName: "play.fill")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(DH.pinkDeep))
                        .padding(12)
                }

                VStack {
                    Spacer()
                    HStack {
                        Text(capture.name)
                            .font(DH.font(.microLabel))
                            .tracking(DH.tracking(.microLabel))
                            .foregroundStyle(DH.ink)
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.92), in: Capsule())
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label(L10n.string("common.delete"), systemImage: "trash")
            }
        }
        .accessibilityLabel(deleteMode ? L10n.format("locker.card.delete_accessibility_label", capture.name) : capture.name)
        .task {
            thumbnail = await ThumbnailLoader.shared.load(url: url, kind: capture.kind)
        }
        .accessibilityIdentifier("locker-card-\(capture.id.uuidString)")
    }
}

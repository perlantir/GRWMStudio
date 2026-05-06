import SwiftUI
import UIKit

struct FeedCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let capture: SavedCapture
    let url: URL
    let metadata: String
    let onDelete: () -> Void

    @State private var thumbnail: UIImage?

    private var cardHeight: CGFloat {
        capture.kind == .video ? 238 : 208
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 22)
                .fill(DH.pinkPaper)
                .chunkyShadow(.md(deep: DH.pink), shape: RoundedRectangle(cornerRadius: 22))

            media

            if capture.kind == .video {
                Image(systemName: "play.fill")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(DH.pinkDeep, in: Circle())
                    .padding(10)
            }

            VStack {
                Spacer()
                footer
            }

            deleteButton
                .padding(10)
                .offset(x: capture.kind == .video ? -38 : 0)
        }
        .frame(height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .task {
            thumbnail = await ThumbnailLoader.shared.load(url: url, kind: capture.kind)
        }
    }

    @ViewBuilder
    private var media: some View {
        if let thumbnail {
            Image(uiImage: thumbnail)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            LinearGradient(
                colors: [DH.pinkLight, DH.pinkPaper, DH.cream],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: capture.kind == .video ? "video.fill" : "photo.fill")
                        .font(.system(size: 26, weight: .heavy))
                    Text(capture.kind == .video ? "feed.capture.video" : "feed.capture.photo")
                        .font(DH.font(.microLabel))
                        .tracking(DH.tracking(.microLabel))
                }
                .foregroundStyle(DH.pinkDeep)
            }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: capture.name)
                .font(DH.font(.buttonLarge))
                .tracking(DH.tracking(.buttonLarge))
                .foregroundStyle(.white)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.72 : 1)

            Text(verbatim: metadata)
                .font(DH.font(.caption))
                .tracking(dynamicTypeSize.isAccessibilitySize ? 0 : DH.tracking(.caption))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.top, 42)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.clear, DH.ink.opacity(0.78)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "trash.fill")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(DH.recRedDeep, in: Circle())
                .overlay(Circle().stroke(.white, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.format("feed.delete.accessibility_label", capture.name))
    }
}

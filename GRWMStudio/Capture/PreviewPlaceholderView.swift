import AVFoundation
import SwiftUI
import UIKit

@MainActor
@Observable
final class PreviewViewModel {
    let asset: CapturedAsset
    let lookName: String?
    private(set) var isMuted = true

    init(asset: CapturedAsset, lookName: String?) {
        self.asset = asset
        self.lookName = lookName
    }

    var displayLookName: String {
        lookName ?? "Custom mix"
    }

    func toggleMute() {
        isMuted.toggle()
    }
}

struct PreviewPlaceholderView: View {
    let asset: CapturedAsset
    let lookName: String?
    let onSave: @MainActor () async throws -> Void
    let onShare: @MainActor () -> Void
    let onDiscard: @MainActor () -> Void

    @State private var viewModel: PreviewViewModel
    @State private var saving = false
    @State private var saveFailed = false

    init(
        asset: CapturedAsset,
        lookName: String? = nil,
        onSave: @escaping @MainActor () async throws -> Void = {},
        onShare: @escaping @MainActor () -> Void = {},
        onDiscard: @escaping @MainActor () -> Void
    ) {
        self.asset = asset
        self.lookName = lookName
        self.onSave = onSave
        self.onShare = onShare
        self.onDiscard = onDiscard
        _viewModel = State(initialValue: PreviewViewModel(asset: asset, lookName: lookName))
    }

    var body: some View {
        GeometryReader { proxy in
            let metrics = PreviewLayoutMetrics(size: proxy.size, safeAreaInsets: proxy.safeAreaInsets)

            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [DH.pinkPaper, DH.cream],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: metrics.verticalSpacing) {
                    topChrome
                        .frame(height: metrics.topBarHeight)

                    mediaCard
                        .frame(width: metrics.mediaWidth, height: metrics.mediaHeight)

                    if saveFailed {
                        SaveFailureBanner()
                            .padding(.horizontal, 18)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Spacer(minLength: 0)

                    bottomActions
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                .padding(.top, metrics.topPadding)
                .padding(.bottom, metrics.bottomPadding)
            }
        }
        .preferredColorScheme(.light)
    }

    private var topChrome: some View {
        ZStack {
            Text("Preview")
                .font(DH.font(.buttonLarge))
                .tracking(DH.tracking(.buttonLarge))
                .foregroundStyle(DH.pinkDeep)
                .accessibilityIdentifier("preview-title")

            HStack {
                Button {
                    onDiscard()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(DH.pinkDeep)
                        .frame(width: 42, height: 42)
                        .background {
                            Circle()
                                .fill(.white)
                                .chunkyShadow(.sm(deep: DH.pinkDeep), shape: Circle())
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Discard preview and return to mirror")
                .accessibilityIdentifier("preview-discard-button")

                Spacer()

                lookTagChip(viewModel.displayLookName)
            }
        }
        .padding(.horizontal, 18)
    }

    private func lookTagChip(_ name: String) -> some View {
        HStack(spacing: 6) {
            StickerStar(size: 14, fill: DH.butter, stroke: .white, strokeWidth: 2)

            Text(name)
                .font(DH.font(.buttonSmall))
                .tracking(DH.tracking(.buttonSmall))
                .foregroundStyle(DH.ink)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .frame(height: 34)
        .background {
            Capsule()
                .fill(.white.opacity(0.96))
                .chunkyShadow(.sm(deep: DH.pink), shape: Capsule())
        }
        .accessibilityIdentifier("preview-look-chip")
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
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: DH.Radius.bigCard)
                    .fill(.white)
                    .chunkyShadow(.md(deep: DH.pink), shape: RoundedRectangle(cornerRadius: DH.Radius.bigCard))
            }
    }

    @ViewBuilder
    private var assetView: some View {
        switch asset {
        case .photo(let image):
            ZoomablePreviewImage(image: image)
                .accessibilityLabel("Photo Preview")

        case .video(let url):
            ZStack(alignment: .bottomTrailing) {
                LoopingVideoPreview(url: url, isMuted: viewModel.isMuted)
                    .onTapGesture {
                        viewModel.toggleMute()
                    }

                Button {
                    viewModel.toggleMute()
                } label: {
                    Image(systemName: viewModel.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(DH.ink.opacity(0.62)))
                }
                .buttonStyle(.plain)
                .padding(14)
                .accessibilityLabel(viewModel.isMuted ? "Unmute video preview" : "Mute video preview")
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("captured-video-preview")
        }
    }

    private var bottomActions: some View {
        HStack(spacing: 12) {
            DHButton(
                title: saving ? "Saving..." : "Save to Locker",
                kind: .primary,
                size: .xl,
                leadingIcon: AnyView(Image(systemName: "heart.fill").foregroundStyle(DH.butter)),
                isFullWidth: true
            ) {
                guard !saving else {
                    return
                }

                saving = true
                Task { @MainActor in
                    saveFailed = false
                    do {
                        try await onSave()
                    } catch {
                        saveFailed = true
                    }
                    saving = false
                }
            }
            .accessibilityLabel("Save to Locker")

            DHButton(
                title: "Share",
                kind: .ghost,
                size: .lg,
                leadingIcon: AnyView(Image(systemName: "square.and.arrow.up")),
                action: onShare
            )
            .frame(width: 142)
            .accessibilityLabel("Share")
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 54)
    }
}

private struct PreviewLayoutMetrics {
    let mediaWidth: CGFloat
    let mediaHeight: CGFloat
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    let topBarHeight: CGFloat = 54
    let verticalSpacing: CGFloat = 14

    init(size: CGSize, safeAreaInsets: EdgeInsets) {
        let horizontalPadding: CGFloat = 18
        mediaWidth = max(280, size.width - horizontalPadding * 2)
        topPadding = safeAreaInsets.top + 8
        bottomPadding = max(safeAreaInsets.bottom, 12)

        let reservedHeight = topPadding + topBarHeight + bottomPadding + 138 + verticalSpacing * 2
        let availableHeight = max(280, size.height - reservedHeight)
        mediaHeight = min(availableHeight, mediaWidth * 4.0 / 3.0)
    }
}

private struct ZoomablePreviewImage: UIViewRepresentable {
    let image: UIImage

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true

        scrollView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.doubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)

        context.coordinator.imageView = imageView
        context.coordinator.scrollView = scrollView
        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.imageView?.image = image
        if scrollView.zoomScale < scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        }
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        weak var imageView: UIImageView?
        weak var scrollView: UIScrollView?

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            imageView
        }

        @objc func doubleTapped(_ recognizer: UITapGestureRecognizer) {
            guard let scrollView else {
                return
            }

            let targetZoom = scrollView.zoomScale > 1 ? 1 : min(2, scrollView.maximumZoomScale)
            scrollView.setZoomScale(targetZoom, animated: true)
        }
    }
}

private struct LoopingVideoPreview: View {
    let url: URL
    let isMuted: Bool
    @State private var player = AVQueuePlayer()
    @State private var looper: AVPlayerLooper?

    var body: some View {
        VideoLayerView(player: player)
            .background(.black)
            .onAppear {
                configurePlayer()
            }
            .onDisappear {
                player.pause()
                player.removeAllItems()
                looper = nil
            }
            .onChange(of: isMuted) { _, muted in
                player.isMuted = muted
            }
    }

    private func configurePlayer() {
        guard looper == nil else {
            player.isMuted = isMuted
            player.play()
            return
        }

        let item = AVPlayerItem(url: url)
        looper = AVPlayerLooper(player: player, templateItem: item)
        player.isMuted = isMuted
        player.play()
    }
}

private struct VideoLayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context _: Context) -> PlayerLayerView {
        let view = PlayerLayerView()
        view.playerLayer?.player = player
        view.playerLayer?.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ view: PlayerLayerView, context _: Context) {
        view.playerLayer?.player = player
    }
}

private final class PlayerLayerView: UIView {
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer? {
        layer as? AVPlayerLayer
    }
}

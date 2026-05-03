import SwiftUI

struct PreviewPlaceholderView: View {
    let asset: CapturedAsset
    let onClose: () -> Void

    var body: some View {
        ZStack {
            DHWallpaperGradient()
                .ignoresSafeArea()

            assetView
                .clipShape(RoundedRectangle(cornerRadius: DH.Radius.viewportInner))
                .overlay {
                    RoundedRectangle(cornerRadius: DH.Radius.viewportInner)
                        .strokeBorder(.white, lineWidth: 6)
                }
                .chunkyShadow(.lg(deep: DH.pinkDeep), shape: RoundedRectangle(cornerRadius: DH.Radius.viewportInner))
                .padding(.horizontal, 18)
                .padding(.vertical, 92)

            VStack {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundStyle(DH.pinkDeep)
                            .frame(width: 48, height: 48)
                            .background(Circle().fill(.white))
                            .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close preview")

                    Spacer()
                }
                .padding(.top, 64)
                .padding(.horizontal, 18)

                Spacer()

                Text("Photo Preview")
                    .font(DH.font(.caption))
                    .tracking(DH.tracking(.caption))
                    .foregroundStyle(DH.pinkDeep)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(.white.opacity(0.9)))
                    .padding(.bottom, 42)
            }
        }
        .preferredColorScheme(.light)
        .accessibilityIdentifier("preview-placeholder")
    }

    @ViewBuilder
    private var assetView: some View {
        switch asset {
        case .photo(let image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .accessibilityLabel("Captured photo preview")

        case .video:
            ZStack {
                DH.pinkPaper
                Image(systemName: "play.fill")
                    .font(.system(size: 54, weight: .heavy))
                    .foregroundStyle(DH.pinkDeep)
            }
            .accessibilityLabel("Captured video preview")
        }
    }
}

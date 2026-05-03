import SwiftUI

enum MirrorChrome {
    @MainActor
    static func top() -> some View {
        HStack(alignment: .center) {
            GRWMLogo(layout: .row, size: .md)
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background {
                    Capsule()
                        .fill(.white)
                        .chunkyShadow(.md(deep: DH.pink), shape: Capsule())
                }

            Spacer()

            StickerHeart(size: 28, fill: .white, stroke: DH.pinkDeep, strokeWidth: 2.8)
                .frame(width: 46, height: 46)
                .background {
                    Circle()
                        .fill(DH.pink)
                        .chunkyShadow(.md(deep: DH.pinkDeep), shape: Circle())
                }
                .rotationEffect(.degrees(8))
                .accessibilityLabel("Favorite looks")
        }
    }
}

#Preview("Mirror Chrome") {
    MirrorChrome.top()
        .padding(18)
        .background(DH.pinkPaper)
}

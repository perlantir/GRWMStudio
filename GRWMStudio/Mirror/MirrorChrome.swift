import SwiftUI

enum MirrorChrome {
    @MainActor
    static func top(onReset: @escaping @MainActor () -> Void) -> some View {
        HStack(alignment: .center) {
            GRWMLogo(layout: .row, size: .lg)
                .padding(.horizontal, 16)
                .frame(width: 154, height: 54)
                .background {
                    Capsule()
                        .fill(.white)
                        .chunkyShadow(.md(deep: DH.pink), shape: Capsule())
                }

            Spacer()

            HStack(spacing: 10) {
                StickerHeart(size: 28, fill: .white, stroke: DH.pinkDeep, strokeWidth: 2.8)
                    .frame(width: 46, height: 46)
                    .background {
                        Circle()
                            .fill(DH.pink)
                            .chunkyShadow(.md(deep: DH.pinkDeep), shape: Circle())
                    }
                    .rotationEffect(.degrees(8))
                    .accessibilityLabel("Favorite looks")

                MirrorResetButton(action: onReset)
            }
        }
    }
}

private struct MirrorResetButton: View {
    let action: @MainActor () -> Void
    @State private var bounceToken = false

    var body: some View {
        Button {
            withAnimation(.bouncy(duration: 0.22)) {
                bounceToken.toggle()
            }
            action()
        } label: {
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(DH.pinkDeep)
                .frame(width: 42, height: 42)
                .background {
                    Circle()
                        .fill(.white)
                        .chunkyShadow(.sm(deep: DH.pinkDeep), shape: Circle())
                }
                .symbolEffect(.bounce, value: bounceToken)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Reset everything")
    }
}

#Preview("Mirror Chrome") {
    MirrorChrome.top {}
        .padding(18)
        .background(DH.pinkPaper)
}

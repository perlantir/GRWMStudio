import SwiftUI

enum MirrorChrome {
    @MainActor
    static func top(
        onFavoriteLooks: @escaping @MainActor () -> Void,
        onReset: @escaping @MainActor () -> Void
    ) -> some View {
        HStack(alignment: .center) {
            GRWMLogo(layout: .stack, size: .md)
                .fixedSize(horizontal: true, vertical: true)
                .frame(width: 190, height: 54)
                .background {
                    Capsule()
                        .fill(.white)
                        .chunkyShadow(.md(deep: DH.pink), shape: Capsule())
                }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    DHHaptics.shared.fire(.pop)
                    onFavoriteLooks()
                } label: {
                    Label {
                        Text("mirror.chrome.favorite_looks")
                    } icon: {
                        StickerHeart(size: 28, fill: .white, stroke: DH.pinkDeep, strokeWidth: 2.8)
                            .frame(width: 46, height: 46)
                            .background {
                                Circle()
                                    .fill(DH.pink)
                                    .chunkyShadow(.md(deep: DH.pinkDeep), shape: Circle())
                            }
                            .rotationEffect(.degrees(8))
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.string("mirror.chrome.favorite_looks"))
                .accessibilityHint(L10n.string("mirror.chrome.favorite_looks.hint"))
                .accessibilityIdentifier("favorite-looks-button")

                MirrorResetButton(action: onReset)
            }
        }
    }
}

private struct MirrorResetButton: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let action: @MainActor () -> Void
    @State private var bounceToken = false

    var body: some View {
        Button {
            withAnimation(DHAnim.respecting(.quickPop, reduceMotion: reduceMotion)) {
                bounceToken.toggle()
            }
            action()
        } label: {
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(DH.pinkDeep)
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .fill(.white)
                        .chunkyShadow(.sm(deep: DH.pinkDeep), shape: Circle())
                }
                .symbolEffect(.bounce, value: bounceToken)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.string("mirror.chrome.reset"))
        .accessibilityHint(L10n.string("mirror.chrome.reset.hint"))
    }
}

#Preview("Mirror Chrome") {
    MirrorChrome.top {} onReset: {}
        .padding(18)
        .background(DH.pinkPaper)
}

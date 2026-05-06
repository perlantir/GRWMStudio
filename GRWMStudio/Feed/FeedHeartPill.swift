import SwiftUI

struct FeedHeartPill: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let favorited: Bool
    let action: () -> Void

    @State private var bouncing = false

    var body: some View {
        Button {
            withAnimation(DHAnim.respecting(.quickPop, reduceMotion: reduceMotion)) {
                bouncing = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                bouncing = false
            }
            DHAudio.shared.play(.heart)
            DHHaptics.shared.fire(.tap)
            action()
        } label: {
            Image(systemName: favorited ? "heart.fill" : "heart")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(favorited ? .white : DH.pinkDeep)
                .frame(width: 30, height: 30)
                .background(favorited ? DH.pink : .white, in: Circle())
                .chunkyShadow(.sm(deep: DH.pinkDeep.opacity(0.4)), shape: Circle())
                .scaleEffect(bouncing ? 1.18 : 1)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .dhAnimation(.quickPop, value: bouncing)
        .accessibilityLabel(favorited ? L10n.string("feed.favorite.remove") : L10n.string("feed.favorite.add"))
        .accessibilityHint(L10n.string("feed.favorite.hint"))
    }
}

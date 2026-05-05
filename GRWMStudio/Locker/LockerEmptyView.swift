import SwiftUI

struct LockerEmptyView: View {
    @Environment(\.appShellSelector) private var selectTab

    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                RoundedRectangle(cornerRadius: DH.Radius.bigCard)
                    .fill(.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: DH.Radius.bigCard)
                            .strokeBorder(DH.pink, style: StrokeStyle(lineWidth: 4, dash: [8, 6]))
                    }
                    .chunkyShadow(.md(deep: DH.pinkLight), shape: RoundedRectangle(cornerRadius: DH.Radius.bigCard))

                Text("💼")
                    .font(.system(size: 88))

                StickerHeart(size: 34, fill: DH.pinkDeep, stroke: .white, strokeWidth: 3)
                    .rotationEffect(.degrees(15))
                    .offset(x: 74, y: -76)

                StickerSparkle(size: 28, fill: DH.butter)
                    .rotationEffect(.degrees(-14))
                    .offset(x: -70, y: 76)
            }
            .frame(width: 180, height: 180)

            VStack(spacing: 8) {
                Text("locker.empty.title")
                    .font(DH.font(.display3))
                    .tracking(DH.tracking(.display3))
                    .foregroundStyle(DH.pinkDeep)
                    .multilineTextAlignment(.center)

                Text("locker.empty.subtitle")
                    .font(DH.font(.body))
                    .tracking(DH.tracking(.body))
                    .foregroundStyle(DH.ink.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
            }

            DHButton(
                title: L10n.string("locker.empty.cta"),
                kind: .primary,
                size: .xl,
                leadingIcon: AnyView(Image(systemName: "sparkles")),
                isFullWidth: true
            ) {
                selectTab(.mirror)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("locker-empty-state")
    }
}

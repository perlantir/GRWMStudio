import SwiftUI

struct EmptyShadeTrayView: View {
    let category: FilterCategory
    let message: String

    var body: some View {
        DHCard(bg: DH.butter, deep: DH.pinkDeep, cornerRadius: DH.Radius.card, padding: 14) {
            HStack(spacing: 10) {
                StickerSparkle(size: 24, fill: DH.pinkDeep, stroke: .white, strokeWidth: 2.5)

                Text(message)
                    .font(DH.font(.body))
                    .foregroundStyle(DH.ink)
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }
        }
        .frame(height: 112)
        .padding(.horizontal, 14)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.format("mirror.empty_shade.accessibility_label", category.label, message))
    }
}

#Preview("Empty Shade Tray") {
    ZStack {
        DHWallpaperGradient()
        VStack {
            Spacer()
            EmptyShadeTrayView(
                category: .brows,
                message: "Brows coming soon ✨ — your bigger pack will unlock these!"
            )
            .padding(.bottom, 180)
        }
    }
}

import SwiftUI
import UIKit

struct NoFaceTipView: View {
    private let announcement = "I can't see your face! Move into the light, or come a little closer."

    var body: some View {
        DHCard(bg: .white, deep: DH.pink, cornerRadius: DH.Radius.card, padding: 14) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 999)
                    .fill(DH.lavender)
                    .frame(width: 5, height: 48)

                StickerSparkle(size: 24, fill: DH.pink, stroke: .white, strokeWidth: 2)

                VStack(alignment: .leading, spacing: 3) {
                    Text("I can't see your face!")
                        .font(DH.font(.buttonLarge))
                        .tracking(DH.tracking(.buttonLarge))
                        .foregroundStyle(DH.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text("Move into the light, or come a little closer.")
                        .font(DH.font(.body))
                        .tracking(DH.tracking(.body))
                        .foregroundStyle(DH.ink.opacity(0.72))
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 24)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
        .onAppear {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }
}

#Preview("No Face Tip") {
    ZStack {
        DHWallpaperGradient()
        NoFaceTipView()
            .padding(.top, 120)
    }
}

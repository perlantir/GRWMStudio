import SwiftUI

struct FeedCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let item: FeedItem
    let favorited: Bool
    let onHeart: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 22)
                .fill(item.palette.card)
                .chunkyShadow(.md(deep: item.palette.deep), shape: RoundedRectangle(cornerRadius: 22))

            cardBody
        }
        .frame(height: item.cardHeight.points)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var cardBody: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                Spacer()
                Image(systemName: "face.smiling.inverse")
                    .resizable()
                    .scaledToFit()
                    .frame(height: item.cardHeight.points * 0.44)
                    .foregroundStyle(item.palette.deep.opacity(0.82))
                    .padding(.bottom, 18)
            }

            LinearGradient(
                colors: [.clear, item.palette.deep.opacity(0.88)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Spacer()

                Text(verbatim: item.localizedDisplayTitle)
                    .font(DH.font(.buttonLarge))
                    .tracking(DH.tracking(.buttonLarge))
                    .foregroundStyle(.white)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.72 : 1)

                Text(verbatim: item.localizedTagline)
                    .font(DH.font(.bodyEmphasis))
                    .tracking(DH.tracking(.bodyEmphasis))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.72 : 1)

                HStack(spacing: 6) {
                    Image(systemName: favorited ? "heart.fill" : "heart")
                        .font(.system(size: 12, weight: .heavy))

                        Text("\(item.hearts + (favorited ? 1 : 0))")
                            .font(DH.font(.caption))
                            .tracking(DH.tracking(.caption))
                }
                .foregroundStyle(.white)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            FeedHeartPill(favorited: favorited, action: onHeart)
                .padding(10)

            if item.hot {
                Text("feed.hot")
                    .font(DH.font(.microLabel))
                    .tracking(DH.tracking(.microLabel))
                    .foregroundStyle(DH.ink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(DH.butter, in: Capsule())
                    .chunkyShadow(.sm(deep: DH.butterDeep), shape: Capsule())
                    .padding(10)
            }
        }
    }
}

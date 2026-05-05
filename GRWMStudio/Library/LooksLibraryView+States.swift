import SwiftUI

extension LooksLibraryView {
    var proBadge: some View {
        HStack(spacing: 4) {
            StickerStar(size: 14, fill: DH.butter)
            if !entitlements.isPro {
                Image(systemName: "lock.fill")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(DH.ink)
            }
            Text(L10n.string(entitlements.isPro ? "common.pro" : "common.locked"))
                .font(DH.font(.microLabel))
                .tracking(DH.tracking(.microLabel))
                .foregroundStyle(DH.ink)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.white.opacity(0.88), in: Capsule())
        .padding(.leading, 8)
        .padding(.top, 84)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var loadingState: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(0..<6, id: \.self) { _ in
                VStack(spacing: 0) {
                    DHSkeleton(shape: AnyShape(RoundedRectangle(cornerRadius: 18)))
                        .frame(height: 116)

                    VStack(spacing: 8) {
                        DHSkeleton(shape: AnyShape(RoundedRectangle(cornerRadius: 10)))
                            .frame(height: 16)
                        DHSkeleton(shape: AnyShape(RoundedRectangle(cornerRadius: 10)))
                            .frame(width: 72, height: 12)
                    }
                    .padding(12)
                }
                .background(.white, in: RoundedRectangle(cornerRadius: 20))
            }
        }
    }

    var emptyState: some View {
        DHCard(bg: .white, deep: DH.pinkLight, cornerRadius: DH.Radius.card, padding: 22) {
            VStack(spacing: 14) {
                StickerSparkle(size: 34, fill: DH.butter)

                Text("looks.empty.title")
                    .font(DH.font(.headline))
                    .tracking(DH.tracking(.headline))
                    .foregroundStyle(DH.pinkDeep)

                Text("looks.empty.subtitle")
                    .font(DH.font(.body))
                    .tracking(DH.tracking(.body))
                    .foregroundStyle(DH.ink.opacity(0.68))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

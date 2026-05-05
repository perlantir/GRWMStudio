import SwiftUI

struct LookDetailView: View {
    @Environment(ProEntitlements.self) private var entitlements
    let look: LookPreset
    let isFavorited: Bool
    let onToggleFavorite: () -> Void
    let onTryItOn: () -> Void
    let onDismiss: () -> Void

    @State private var showTutorial = !UserDefaults.standard.bool(forKey: "dh_seen_look_tutorial")

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [DH.pinkLight, DH.pink, DH.pinkDeep],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    heroCard
                        .padding(.top, 76)

                    detailCard
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 140)
            }

            HStack {
                glassCircleButton(systemName: "chevron.left", action: onDismiss)
                Spacer(minLength: 0)
                glassCircleButton(
                    systemName: isFavorited ? "heart.fill" : "heart",
                    action: onToggleFavorite
                )
            }
            .padding(.horizontal, 18)
            .padding(.top, 58)

            VStack {
                Spacer()
                DHButton(
                    title: callToActionTitle,
                    kind: .primary,
                    size: .xl,
                    leadingIcon: AnyView(Image(systemName: "sparkles")),
                    isFullWidth: true,
                    action: onTryItOn
                )
                .padding(.horizontal, 18)
                .padding(.bottom, 28)
            }

            if showTutorial {
                LookTutorialOverlay {
                    showTutorial = false
                    UserDefaults.standard.set(true, forKey: "dh_seen_look_tutorial")
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private var heroCard: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 28)
                .fill(.white)
                .chunkyShadow(.lg(deep: DH.pinkDeep), shape: RoundedRectangle(cornerRadius: 28))

            lookHero
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(10)

            if look.isPro {
                HStack(spacing: 6) {
                    StickerStar(size: 16, fill: DH.butter)
                    if !entitlements.isPro {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(DH.ink)
                    }
                    Text(L10n.string(entitlements.isPro ? "common.pro" : "common.locked"))
                        .font(DH.font(.microLabel))
                        .tracking(DH.tracking(.microLabel))
                        .foregroundStyle(DH.ink)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.9), in: Capsule())
                .padding(18)
            }
        }
        .frame(height: 360)
    }

    private var detailCard: some View {
        DHCard(bg: .white, deep: DH.pink, cornerRadius: DH.Radius.card, padding: 18) {
            VStack(alignment: .leading, spacing: 14) {
                Text(verbatim: look.localizedName)
                    .font(DH.font(.display3))
                    .tracking(DH.tracking(.display3))
                    .foregroundStyle(DH.pinkDeep)

                Text(LookCopy.description(for: look.id))
                    .font(DH.font(.body))
                    .tracking(DH.tracking(.body))
                    .foregroundStyle(DH.ink.opacity(0.75))

                Text("looks.detail.composition_title")
                    .font(DH.font(.headline))
                    .tracking(DH.tracking(.headline))
                    .foregroundStyle(DH.ink)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
                    ForEach(LookCopy.composition(for: look.id), id: \.self) { line in
                        Text(line)
                            .font(DH.font(.body))
                            .tracking(DH.tracking(.body))
                            .foregroundStyle(DH.ink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(DH.pinkPaper, in: RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var lookHero: some View {
        AsyncBundleImage(assetName: look.thumbnailAsset, subdirectory: "Effects/thumbnails") {
            LinearGradient(
                colors: look.isPro ? [DH.lavender, DH.pink, DH.pinkDeep] : [DH.pinkLight, DH.pinkPaper, DH.cream],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                VStack(spacing: 12) {
                    StickerSparkle(size: 40, fill: .white)
                    Text(verbatim: look.localizedName)
                        .font(DH.font(.headline))
                        .tracking(DH.tracking(.headline))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
        }
        .scaledToFill()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func glassCircleButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.24), in: Circle())
        }
        .buttonStyle(.plain)
    }

    private var callToActionTitle: String {
        if look.isPro && !entitlements.isPro {
            return L10n.string("looks.detail.cta.unlock_pro")
        }

        return L10n.string("looks.detail.cta.try")
    }
}

import SwiftUI
import UIKit

struct LooksTrayView: View {
    @Environment(ProEntitlements.self) private var entitlements
    @Bindable var viewModel: MirrorViewModel
    var onSelectionComplete: () -> Void = {}

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Looks.all) { look in
                    lookCard(look)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .frame(height: 148)
        .padding(.horizontal, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .accessibilityIdentifier("looks-tray")
    }

    private func lookCard(_ look: LookPreset) -> some View {
        let available = EffectCatalog.shared.containsSync(effectID: look.effectID)
        let active = viewModel.selectedLookEffectID == look.effectID

        return Button {
            Task { @MainActor in
                await viewModel.selectLook(look)
                if viewModel.selectedLookEffectID == look.effectID {
                    onSelectionComplete()
                }
            }
            DHHaptics.tapMedium()
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 0) {
                    thumbnail(for: look, available: available)
                        .frame(height: 66)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding([.horizontal, .top], 7)

                    Text(verbatim: look.localizedName)
                        .font(DH.font(.buttonSmall))
                        .tracking(DH.tracking(.buttonSmall))
                        .foregroundStyle(DH.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .padding(.horizontal, 7)
                }
                .frame(width: 100, height: 120)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .chunkyShadow(.md(deep: active ? DH.lavenderDeep : DH.pink), shape: RoundedRectangle(cornerRadius: 20))
                )
                .overlay {
                    if active {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(DH.pinkDeep, lineWidth: 3)
                    }
                }
                .opacity(available ? 1 : 0.55)

                badgeOverlay(look: look, available: available)
            }
            .frame(width: 106, height: 126)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel(for: look, available: available))
        .accessibilityValue(active ? L10n.string("common.selected") : L10n.string("common.not_selected"))
        .accessibilityHint(L10n.string("mirror.looks.accessibility_hint"))
        .accessibilityAddTraits(active ? [.isSelected] : [])
    }

    private func thumbnail(for look: LookPreset, available: Bool) -> some View {
        AsyncBundleImage(assetName: look.thumbnailAsset, subdirectory: "Effects/thumbnails") {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(DH.pinkLight)
                StickerSparkle(size: 28, fill: DH.pinkDeep, stroke: .white, strokeWidth: 2)
            }
        }
        .scaledToFill()
        .saturation(available ? 1 : 0.35)
    }

    @ViewBuilder
    private func badgeOverlay(look: LookPreset, available: Bool) -> some View {
        VStack(alignment: .trailing, spacing: 5) {
            if look.isPro {
                ZStack {
                    StickerStar(size: 24, fill: DH.butter, stroke: .white, strokeWidth: 3)

                    if !entitlements.isPro {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundStyle(DH.ink)
                    }
                }
            }

            if !available {
                Text("mirror.looks.soon")
                    .font(DH.font(.microLabel))
                    .tracking(DH.tracking(.microLabel))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(width: 58, height: 22)
                    .background(Capsule().fill(DH.pinkDeep))
            }
        }
        .offset(x: 4, y: -4)
    }
    private func accessibilityLabel(for look: LookPreset, available: Bool) -> String {
        var parts = [look.localizedName, L10n.string("mirror.looks.accessibility_noun")]
        if look.isPro {
            parts.append(entitlements.isPro ? L10n.string("common.pro") : L10n.string("common.pro_locked"))
        }
        if !available {
            parts.append(L10n.string("mirror.looks.coming_soon"))
        }
        return parts.joined(separator: ", ")
    }
}

#Preview("Looks Tray") {
    @Previewable @State var viewModel = MirrorViewModel()

    ZStack {
        DHWallpaperGradient()
        VStack {
            Spacer()
            LooksTrayView(viewModel: viewModel)
                .padding(.bottom, 180)
        }
    }
}

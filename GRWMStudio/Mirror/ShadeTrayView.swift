import SwiftUI

struct ShadeTrayView: View {
    @Environment(ProEntitlements.self) private var entitlements
    let category: FilterCategory
    let shades: [Shade]
    let selectedID: String?
    let onSelect: (Shade) -> Void
    let onClear: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                clearChip

                ForEach(Array(shades.enumerated()), id: \.element.id) { index, shade in
                    swatch(shade, index: index)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .frame(height: 112)
        .background {
            RoundedRectangle(cornerRadius: DH.Radius.card)
                .fill(.white.opacity(0.92))
                .chunkyShadow(.md(deep: DH.pink), shape: RoundedRectangle(cornerRadius: DH.Radius.card))
        }
        .padding(.horizontal, 12)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .accessibilityIdentifier("shade-tray-\(category.rawValue)")
    }

    private var clearChip: some View {
        Button {
            onClear()
            DHHaptics.light()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "xmark")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(DH.pinkDeep)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(DH.cream))
                    .chunkyShadow(.sm(deep: DH.pink), shape: Circle())

                Text("mirror.shade.clear")
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
                    .foregroundStyle(DH.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 64, height: 86)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.format("mirror.shade.clear.accessibility_label", category.label))
        .accessibilityHint(L10n.format("mirror.shade.clear.accessibility_hint", category.label.lowercased()))
    }

    private func swatch(_ shade: Shade, index: Int) -> some View {
        let active = shade.id == selectedID

        return Button {
            onSelect(shade)
            DHHaptics.tapMedium()
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(shade.swatchColor)
                        .frame(width: 56, height: 56)
                        .overlay(Circle().strokeBorder(.white, lineWidth: 4))

                    if active {
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundStyle(.white)
                    }

                    if shade.isPro && !entitlements.isPro {
                        ZStack {
                            StickerStar(size: 22, fill: DH.butter, stroke: .white, strokeWidth: 3)

                            Image(systemName: "lock.fill")
                                .font(.system(size: 8, weight: .heavy))
                                .foregroundStyle(DH.ink)
                        }
                        .offset(x: 22, y: -22)
                    }
                }
                .scaleEffect(active ? 1.1 : 1)
                .dhAnimation(.quickPop, value: active)
                .chunkyShadow(.sm(deep: DH.pinkDeep), shape: Circle())

                Text(verbatim: shade.localizedName)
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
                    .foregroundStyle(DH.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .multilineTextAlignment(.center)
                    .frame(height: 26)
            }
            .frame(width: 64, height: 86)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.format("mirror.shade.accessibility_label", shade.localizedName, category.label))
        .accessibilityValue(accessibilityValue(for: shade, active: active, index: index))
        .accessibilityHint(L10n.string("mirror.shade.accessibility_hint"))
        .accessibilityIdentifier("\(shade.localizedName) \(category.label) shade")
        .accessibilityAddTraits(active ? [.isSelected] : [])
    }

    private func accessibilityValue(for shade: Shade, active: Bool, index: Int) -> String {
        var parts = [L10n.format("common.index_of_total", index + 1, shades.count)]
        if active {
            parts.append(L10n.string("common.selected"))
        }
        if shade.isPro {
            parts.append(entitlements.isPro ? L10n.string("common.pro") : L10n.string("common.pro_locked"))
        }
        return parts.joined(separator: ", ")
    }
}

#Preview("Shade Tray") {
    ZStack {
        DHWallpaperGradient()
        VStack {
            Spacer()
            ShadeTrayView(category: .skin, shades: Shade.skinShades, selectedID: "skin.medium") { _ in } onClear: {}
                .padding(.bottom, 180)
        }
    }
}

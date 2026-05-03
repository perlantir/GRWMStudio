import SwiftUI

struct ShadeTrayView: View {
    let category: FilterCategory
    let shades: [Shade]
    let selectedID: String?
    let onSelect: (Shade) -> Void
    let onClear: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                clearChip

                ForEach(shades) { shade in
                    swatch(shade)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .frame(height: 104)
        .background {
            RoundedRectangle(cornerRadius: DH.Radius.card)
                .fill(.white.opacity(0.92))
                .chunkyShadow(.md(deep: DH.pink), shape: RoundedRectangle(cornerRadius: DH.Radius.card))
        }
        .padding(.horizontal, 12)
        .transition(.move(edge: .bottom).combined(with: .opacity))
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

                Text("Clear")
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
                    .foregroundStyle(DH.ink)
            }
            .frame(width: 64, height: 82)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Clear \(category.label) filter")
    }

    private func swatch(_ shade: Shade) -> some View {
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
                }
                .scaleEffect(active ? 1.1 : 1)
                .animation(.bouncy(duration: 0.22), value: active)
                .chunkyShadow(.sm(deep: DH.pinkDeep), shape: Circle())

                Text(shade.name)
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
                    .foregroundStyle(DH.ink)
            }
            .frame(width: 64, height: 82)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(shade.name) \(category.label) shade\(shade.isPro ? ", Pro" : "")")
        .accessibilityAddTraits(active ? [.isSelected] : [])
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

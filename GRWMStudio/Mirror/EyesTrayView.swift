import SwiftUI

enum EyesSubCategory: String, CaseIterable, Sendable {
    case shadow
    case liner
    case lashes

    var label: String {
        switch self {
        case .shadow:
            L10n.string("mirror.eyes.subcategory.shadow")
        case .liner:
            L10n.string("mirror.eyes.subcategory.liner")
        case .lashes:
            L10n.string("mirror.eyes.subcategory.lashes")
        }
    }
}

struct EyesTrayView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .caption) private var tabMinWidth = 76
    @ScaledMetric(relativeTo: .caption) private var tabHeight = 34
    @Bindable var viewModel: MirrorViewModel
    var onSelectionComplete: () -> Void = {}

    var body: some View {
        VStack(spacing: 8) {
            subTabs

            ShadeTrayView(
                category: .eyes,
                shades: shades(for: viewModel.eyesSubCategory),
                selectedID: viewModel.selectedEyeShadeID(for: viewModel.eyesSubCategory)
            ) { shade in
                Task { @MainActor in
                    await viewModel.selectShade(in: .eyes, shade: shade)
                    onSelectionComplete()
                }
            } onClear: {
                Task { @MainActor in
                    await viewModel.clear(slot: .eyes)
                    onSelectionComplete()
                }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var subTabs: some View {
        HStack(spacing: 6) {
            ForEach(EyesSubCategory.allCases, id: \.self) { subCategory in
                subTab(subCategory)
            }
        }
        .padding(.horizontal, 18)
    }

    private func subTab(_ subCategory: EyesSubCategory) -> some View {
        let active = viewModel.eyesSubCategory == subCategory

        return Button {
            withAnimation(DHAnim.respecting(.quickPop, reduceMotion: reduceMotion)) {
                viewModel.eyesSubCategory = subCategory
            }
            DHHaptics.light()
        } label: {
            Text(verbatim: subCategory.label)
                .font(DH.font(.buttonSmall))
                .tracking(DH.tracking(.buttonSmall))
                .foregroundStyle(active ? .white : DH.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .frame(minWidth: tabMinWidth)
                .frame(height: tabHeight)
                .background(
                    Capsule()
                        .fill(active ? DH.pinkDeep : .white)
                        .chunkyShadow(.sm(deep: DH.pink), shape: Capsule())
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.format("mirror.eyes.subcategory.accessibility_label", subCategory.label))
        .accessibilityValue(active ? L10n.string("common.selected") : L10n.string("common.not_selected"))
        .accessibilityHint(L10n.format("mirror.eyes.subcategory.accessibility_hint", subCategory.label.lowercased()))
        .accessibilityAddTraits(active ? [.isSelected] : [])
    }

    private func shades(for subCategory: EyesSubCategory) -> [Shade] {
        switch subCategory {
        case .shadow:
            Shade.eyeshadowShades
        case .liner:
            Shade.eyelinerShades
        case .lashes:
            Shade.eyelashShades
        }
    }
}

#Preview("Eyes Tray") {
    @Previewable @State var viewModel = MirrorViewModel()

    ZStack {
        DHWallpaperGradient()
        VStack {
            Spacer()
            EyesTrayView(viewModel: viewModel)
                .padding(.bottom, 180)
        }
    }
}

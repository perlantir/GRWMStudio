import SwiftUI

enum EyesSubCategory: String, CaseIterable, Sendable {
    case shadow
    case liner
    case lashes

    var label: String {
        switch self {
        case .shadow:
            "Shadow"
        case .liner:
            "Liner"
        case .lashes:
            "Lashes"
        }
    }
}

struct EyesTrayView: View {
    @Bindable var viewModel: MirrorViewModel

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
                }
            } onClear: {
                Task { @MainActor in
                    await viewModel.clear(slot: .eyes)
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
            withAnimation(.snappy(duration: 0.22)) {
                viewModel.eyesSubCategory = subCategory
            }
            DHHaptics.light()
        } label: {
            Text(subCategory.label)
                .font(DH.font(.buttonSmall))
                .tracking(DH.tracking(.buttonSmall))
                .foregroundStyle(active ? .white : DH.ink)
                .frame(minWidth: 76)
                .frame(height: 34)
                .background(
                    Capsule()
                        .fill(active ? DH.pinkDeep : .white)
                        .chunkyShadow(.sm(deep: DH.pink), shape: Capsule())
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(subCategory.label) eye filter tab")
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

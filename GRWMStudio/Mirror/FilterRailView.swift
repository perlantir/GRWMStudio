import SwiftUI

struct FilterRailView: View {
    @Bindable var viewModel: MirrorViewModel
    var onCategoryTap: (FilterCategory) -> Bool = { _ in false }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FilterCategory.allCases) { category in
                    chip(for: category)
                        .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                            content.scaleEffect(phase.isIdentity ? 1 : 0.98)
                        }
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .scrollTargetBehavior(.viewAligned)
        .frame(height: 64)
        .accessibilityIdentifier("filter-rail")
    }

    private func chip(for category: FilterCategory) -> some View {
        let active = viewModel.activeCategory == category

        return Button {
            guard !onCategoryTap(category) else {
                DHHaptics.light()
                return
            }

            withAnimation(.bouncy(duration: 0.22)) {
                viewModel.activeCategory = category
            }
            DHHaptics.light()
        } label: {
            HStack(spacing: 6) {
                Text(category.emoji)
                    .font(.system(size: 18))

                Text(category.label)
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
                    .foregroundStyle(active ? .white : DH.ink)
            }
            .padding(.horizontal, 14)
            .frame(height: 42)
            .background(chipBackground(active: active))
            .overlay(alignment: .topTrailing) {
                if category == .looks {
                    StickerStar(size: 15, fill: DH.butter, stroke: .white, strokeWidth: 3)
                        .offset(x: 5, y: -5)
                }
            }
            .scaleEffect(active ? 1.06 : 1)
            .animation(.bouncy(duration: 0.22), value: active)
            .frame(minHeight: 54)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(category.label) filter category")
        .accessibilityAddTraits(active ? [.isSelected] : [])
    }

    private func chipBackground(active: Bool) -> some View {
        Capsule()
            .fill(active ? DH.pinkDeep : .white)
            .chunkyShadow(.sm(deep: DH.pink), shape: Capsule())
    }
}

#Preview("Filter Rail") {
    @Previewable @State var viewModel = MirrorViewModel()

    ZStack {
        DHWallpaperGradient()
        VStack {
            Spacer()
            FilterRailView(viewModel: viewModel)
                .padding(.bottom, 120)
        }
    }
}

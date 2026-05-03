import SwiftUI

struct MirrorTrayHostView: View {
    @Bindable var viewModel: MirrorViewModel
    @Binding var pendingCategoryAfterLook: FilterCategory?

    var body: some View {
        VStack {
            Spacer()

            trayView

            if let pendingCategoryAfterLook, let activeLookName = viewModel.activeLookName {
                LookSwitchConfirmationView(
                    lookName: activeLookName,
                    onConfirm: {
                        Task { @MainActor in
                            await viewModel.clear(slot: .looks)
                            withAnimation(.bouncy(duration: 0.22)) {
                                viewModel.activeCategory = pendingCategoryAfterLook
                                self.pendingCategoryAfterLook = nil
                            }
                        }
                    },
                    onCancel: {
                        withAnimation(.bouncy(duration: 0.22)) {
                            self.pendingCategoryAfterLook = nil
                        }
                    }
                )
                .padding(.bottom, 178)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            FilterRailView(viewModel: viewModel) { category in
                handleCategoryTap(category)
            }
            .padding(.bottom, 118)
        }
    }

    @ViewBuilder
    private var trayView: some View {
        switch viewModel.activeCategory {
        case .skin:
            ShadeTrayView(
                category: .skin,
                shades: Shade.skinShades,
                selectedID: viewModel.selectedShadeID(for: .skin)
            ) { shade in
                Task { @MainActor in
                    await viewModel.selectShade(in: .skin, shade: shade)
                }
            } onClear: {
                Task { @MainActor in
                    await viewModel.clear(slot: .skin)
                }
            }
            .padding(.bottom, 186)
            .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)

        case .base:
            ShadeTrayView(
                category: .base,
                shades: Shade.baseShades,
                selectedID: viewModel.selectedShadeID(for: .base) ?? "base.none"
            ) { shade in
                Task { @MainActor in
                    if shade.id == "base.none" {
                        await viewModel.clear(slot: .base)
                    } else {
                        await viewModel.selectShade(in: .base, shade: shade)
                    }
                }
            } onClear: {
                Task { @MainActor in
                    await viewModel.clear(slot: .base)
                }
            }
            .padding(.bottom, 186)
            .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)

        case .eyes:
            EyesTrayView(viewModel: viewModel)
                .padding(.bottom, 186)
                .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)

        case .brows:
            browsTray

        case .cheeks:
            cheeksTray

        case .lips:
            ShadeTrayView(
                category: .lips,
                shades: Shade.lipShades,
                selectedID: viewModel.selectedShadeID(for: .lips)
            ) { shade in
                Task { @MainActor in
                    await viewModel.selectShade(in: .lips, shade: shade)
                }
            } onClear: {
                Task { @MainActor in
                    await viewModel.clear(slot: .lips)
                }
            }
            .padding(.bottom, 186)
            .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)

        case .looks where pendingCategoryAfterLook == nil:
            LooksTrayView(viewModel: viewModel)
                .padding(.bottom, 172)
                .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)

        case .looks, .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private var browsTray: some View {
        if EffectCatalog.shared.containsSync(effectID: "brows") {
            ShadeTrayView(
                category: .brows,
                shades: Shade.browShades,
                selectedID: viewModel.selectedShadeID(for: .brows)
            ) { shade in
                Task { @MainActor in
                    await viewModel.selectShade(in: .brows, shade: shade)
                }
            } onClear: {
                Task { @MainActor in
                    await viewModel.clear(slot: .brows)
                }
            }
            .padding(.bottom, 186)
            .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)
        } else {
            EmptyShadeTrayView(
                category: .brows,
                message: "Brows coming soon ✨ — your bigger pack will unlock these!"
            )
            .padding(.bottom, 186)
            .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)
        }
    }

    @ViewBuilder
    private var cheeksTray: some View {
        if EffectCatalog.shared.containsSync(effectID: "blush") {
            ShadeTrayView(
                category: .cheeks,
                shades: Shade.cheekShades,
                selectedID: viewModel.selectedShadeID(for: .cheeks)
            ) { shade in
                Task { @MainActor in
                    await viewModel.selectShade(in: .cheeks, shade: shade)
                }
            } onClear: {
                Task { @MainActor in
                    await viewModel.clear(slot: .cheeks)
                }
            }
            .padding(.bottom, 186)
            .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)
        } else {
            EmptyShadeTrayView(
                category: .cheeks,
                message: "Blush coming soon ✨"
            )
            .padding(.bottom, 186)
            .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)
        }
    }

    private func handleCategoryTap(_ category: FilterCategory) -> Bool {
        guard viewModel.activeLookName != nil, category != .looks else {
            pendingCategoryAfterLook = nil
            return false
        }

        withAnimation(.bouncy(duration: 0.22)) {
            pendingCategoryAfterLook = category
        }
        return true
    }
}

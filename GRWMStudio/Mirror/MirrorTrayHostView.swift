import SwiftUI

struct MirrorTrayHostView: View {
    @Bindable var viewModel: MirrorViewModel
    @Binding var pendingCategoryAfterLook: FilterCategory?
    private let shadeTrayBottomPadding: CGFloat = 72
    private let looksTrayBottomPadding: CGFloat = 72

    var body: some View {
        VStack {
            Spacer()

            if !viewModel.isRecording {
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
                    .padding(.bottom, 120)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                MirrorBottomControls(viewModel: viewModel)
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))

                FilterRailView(viewModel: viewModel) { category in
                    handleCategoryTap(category)
                }
                .padding(.bottom, 118)
            }
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
                    dismissTray()
                }
            } onClear: {
                Task { @MainActor in
                    await viewModel.clear(slot: .skin)
                    dismissTray()
                }
            }
            .padding(.bottom, shadeTrayBottomPadding)
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
                    dismissTray()
                }
            } onClear: {
                Task { @MainActor in
                    await viewModel.clear(slot: .base)
                    dismissTray()
                }
            }
            .padding(.bottom, shadeTrayBottomPadding)
            .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)

        case .eyes:
            EyesTrayView(viewModel: viewModel) {
                dismissTray()
            }
                .padding(.bottom, shadeTrayBottomPadding)
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
                    dismissTray()
                }
            } onClear: {
                Task { @MainActor in
                    await viewModel.clear(slot: .lips)
                    dismissTray()
                }
            }
            .padding(.bottom, shadeTrayBottomPadding)
            .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)

        case .looks where pendingCategoryAfterLook == nil:
            LooksTrayView(viewModel: viewModel) {
                dismissTray()
            }
                .padding(.bottom, looksTrayBottomPadding)
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
                    dismissTray()
                }
            } onClear: {
                Task { @MainActor in
                    await viewModel.clear(slot: .brows)
                    dismissTray()
                }
            }
            .padding(.bottom, shadeTrayBottomPadding)
            .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)
        } else {
            EmptyShadeTrayView(
                category: .brows,
                message: "Brows coming soon ✨ — your bigger pack will unlock these!"
            )
            .padding(.bottom, shadeTrayBottomPadding)
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
                    dismissTray()
                }
            } onClear: {
                Task { @MainActor in
                    await viewModel.clear(slot: .cheeks)
                    dismissTray()
                }
            }
            .padding(.bottom, shadeTrayBottomPadding)
            .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)
        } else {
            EmptyShadeTrayView(
                category: .cheeks,
                message: "Blush coming soon ✨"
            )
            .padding(.bottom, shadeTrayBottomPadding)
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

    private func dismissTray() {
        withAnimation(.bouncy(duration: 0.22)) {
            viewModel.activeCategory = nil
            pendingCategoryAfterLook = nil
        }
    }
}

import SwiftUI

struct MirrorTrayHostView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var viewModel: MirrorViewModel
    @Binding var pendingCategoryAfterLook: FilterCategory?

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
                                withAnimation(DHAnim.respecting(.quickPop, reduceMotion: reduceMotion)) {
                                    viewModel.activeCategory = pendingCategoryAfterLook
                                    self.pendingCategoryAfterLook = nil
                                }
                            }
                        },
                        onCancel: {
                            withAnimation(DHAnim.respecting(.quickPop, reduceMotion: reduceMotion)) {
                                self.pendingCategoryAfterLook = nil
                            }
                        }
                    )
                    .padding(.bottom, confirmationBottomPadding)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                MirrorBottomControls(viewModel: viewModel)
                    .padding(.bottom, bottomControlsPadding)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))

                FilterRailView(viewModel: viewModel) { category in
                    handleCategoryTap(category)
                }
                .padding(.bottom, filterRailBottomPadding)
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
            .dhAnimation(.softSpring, value: viewModel.activeCategory)

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
            .dhAnimation(.softSpring, value: viewModel.activeCategory)

        case .eyes:
            EyesTrayView(viewModel: viewModel) {
                dismissTray()
            }
                .padding(.bottom, shadeTrayBottomPadding)
                .dhAnimation(.softSpring, value: viewModel.activeCategory)

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
            .dhAnimation(.softSpring, value: viewModel.activeCategory)

        case .looks where pendingCategoryAfterLook == nil:
            LooksTrayView(viewModel: viewModel) {
                dismissTray()
            }
                .padding(.bottom, looksTrayBottomPadding)
                .dhAnimation(.softSpring, value: viewModel.activeCategory)

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
            .dhAnimation(.softSpring, value: viewModel.activeCategory)
        } else {
            EmptyShadeTrayView(
                category: .brows,
                message: "Brows coming soon ✨ — your bigger pack will unlock these!"
            )
            .padding(.bottom, shadeTrayBottomPadding)
            .dhAnimation(.softSpring, value: viewModel.activeCategory)
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
            .dhAnimation(.softSpring, value: viewModel.activeCategory)
        } else {
            EmptyShadeTrayView(
                category: .cheeks,
                message: "Blush coming soon ✨"
            )
            .padding(.bottom, shadeTrayBottomPadding)
            .dhAnimation(.softSpring, value: viewModel.activeCategory)
        }
    }

    private func handleCategoryTap(_ category: FilterCategory) -> Bool {
        guard viewModel.activeLookName != nil, category != .looks else {
            pendingCategoryAfterLook = nil
            return false
        }

        withAnimation(DHAnim.respecting(.quickPop, reduceMotion: reduceMotion)) {
            pendingCategoryAfterLook = category
        }
        return true
    }

    private func dismissTray() {
        withAnimation(DHAnim.respecting(.quickPop, reduceMotion: reduceMotion)) {
            viewModel.activeCategory = nil
            pendingCategoryAfterLook = nil
        }
    }

    private var isAccessibilityLayout: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var shadeTrayBottomPadding: CGFloat {
        isAccessibilityLayout ? 116 : 72
    }

    private var looksTrayBottomPadding: CGFloat {
        isAccessibilityLayout ? 116 : 72
    }

    private var filterRailBottomPadding: CGFloat {
        isAccessibilityLayout ? 152 : 118
    }

    private var bottomControlsPadding: CGFloat {
        isAccessibilityLayout ? 18 : 8
    }

    private var confirmationBottomPadding: CGFloat {
        isAccessibilityLayout ? 150 : 120
    }
}

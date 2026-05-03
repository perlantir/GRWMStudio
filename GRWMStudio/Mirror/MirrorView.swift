import OSLog
import SwiftUI

struct MirrorView: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.rootCoordinator) private var coordinator
    @State private var viewModel = MirrorViewModel()
    @State private var pendingCategoryAfterLook: FilterCategory?

    var body: some View {
        ZStack {
            DHWallpaperGradient()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                MirrorChrome.top {
                    Task { @MainActor in
                        await viewModel.resetAll()
                        pendingCategoryAfterLook = nil
                    }
                }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)

                cameraRegion
                    .padding(.horizontal, 14)
                    .padding(.top, 12)

                Spacer(minLength: 220)
            }

            VStack {
                Spacer()

                if viewModel.activeCategory == .skin {
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
                } else if viewModel.activeCategory == .base {
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
                } else if viewModel.activeCategory == .eyes {
                    EyesTrayView(viewModel: viewModel)
                        .padding(.bottom, 186)
                        .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)
                } else if viewModel.activeCategory == .brows {
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
                } else if viewModel.activeCategory == .cheeks {
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
                } else if viewModel.activeCategory == .lips {
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
                } else if viewModel.activeCategory == .looks, pendingCategoryAfterLook == nil {
                    LooksTrayView(viewModel: viewModel)
                        .padding(.bottom, 172)
                        .animation(.bouncy(duration: 0.32), value: viewModel.activeCategory)
                }

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
        .preferredColorScheme(.light)
        .task {
            await viewModel.start(env: env)
        }
        .onDisappear {
            viewModel.pause()
        }
    }

    @ViewBuilder
    private var cameraRegion: some View {
        switch viewModel.state {
        case .idle, .starting, .running:
            DeepARView(controller: viewModel.controller)
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: DH.Radius.viewportInner))
                .overlay {
                    RoundedRectangle(cornerRadius: DH.Radius.viewportInner)
                        .strokeBorder(.white, lineWidth: 6)
                }
                .chunkyShadow(.lg(deep: DH.pinkDeep), shape: RoundedRectangle(cornerRadius: DH.Radius.viewportInner))
                .accessibilityLabel("Magic mirror camera")

        case .needsPermission:
            permissionCard

        case .failed(let variant):
            DHCard(bg: DH.cream, deep: DH.pink, cornerRadius: DH.Radius.bigCard, padding: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mirror needs a restart")
                        .font(DH.font(.headline))
                        .tracking(DH.tracking(.headline))
                        .foregroundStyle(DH.pinkDeep)

                    Text(errorMessage(for: variant))
                        .font(DH.font(.body))
                        .foregroundStyle(DH.ink.opacity(0.72))
                        .lineLimit(2)
                }
            }
        }
    }

    private var permissionCard: some View {
        DHCard(bg: DH.butter, deep: DH.butterDeep, cornerRadius: DH.Radius.bigCard, padding: 24) {
            HStack(spacing: 14) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(DH.ink)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(.white.opacity(0.65)))

                Text("Tap to allow camera 💕")
                    .font(DH.font(.headline))
                    .tracking(DH.tracking(.headline))
                    .foregroundStyle(DH.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: DH.Radius.bigCard))
        .onTapGesture {
            Logger.deepAR.info("Mirror permission card tapped")
            coordinator.showPermissions()
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Tap to allow camera")
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

#Preview("Mirror View") {
    MirrorView()
        .environment(\.appEnvironment, AppEnvironment())
        .environment(\.rootCoordinator, RootCoordinator())
}

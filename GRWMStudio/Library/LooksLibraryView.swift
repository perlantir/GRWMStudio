import SwiftData
import SwiftUI

struct LooksLibraryView: View {
    @Environment(ProEntitlements.self) var entitlements
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: LooksLibraryViewModel?
    @State private var selectedLook: LookPreset?

    let onTryLookFromGrid: @MainActor (LookPreset) -> Void

    private var debugFreezeLoading: Bool {
        DebugRuntimeFlags.contains("-GRWMDebugFreezeLooksLoading")
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [DH.pinkPaper, DH.cream], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    statsStrip

                    if debugFreezeLoading {
                        loadingState
                    } else if let viewModel {
                        if viewModel.sections.flatMap(\.looks).isEmpty {
                            emptyState
                        } else {
                            ForEach(viewModel.sections) { section in
                                VStack(alignment: .leading, spacing: 10) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(section.title)
                                            .font(DH.font(.headline))
                                            .tracking(DH.tracking(.headline))
                                            .foregroundStyle(DH.pinkDeep)
                                        Text(section.subtitle)
                                            .font(DH.font(.body))
                                            .tracking(DH.tracking(.body))
                                            .foregroundStyle(DH.ink.opacity(0.68))
                                    }

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(section.looks) { look in
                                                lookCard(look, viewModel: viewModel)
                                            }
                                        }
                                        .padding(.horizontal, 2)
                                    }
                                }
                            }
                        }
                    } else {
                        loadingState
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 58)
                .padding(.bottom, 28)
            }
        }
        .task {
            guard !debugFreezeLoading else {
                return
            }
            if viewModel == nil {
                let newViewModel = LooksLibraryViewModel(modelContext)
                try? await Task.sleep(
                    for: DebugRuntimeFlags.delay(
                        .milliseconds(180),
                        slowFlag: "-GRWMDebugSlowLoadingStates"
                    )
                )
                viewModel = newViewModel
                return
            }
            viewModel?.reloadFavorites()
        }
        .fullScreenCover(item: $selectedLook) { look in
            if let viewModel {
                LookDetailView(
                    look: look,
                    isFavorited: viewModel.isFavorited(look.id),
                    onToggleFavorite: {
                        viewModel.toggleFavorite(lookID: look.id)
                    },
                    onTryItOn: {
                        selectedLook = nil
                        onTryLookFromGrid(look)
                    },
                    onDismiss: {
                        selectedLook = nil
                    }
                )
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("looks.eyebrow")
                .font(DH.font(.microLabel))
                .tracking(DH.tracking(.microLabel))
                .foregroundStyle(DH.ink.opacity(0.58))

            HStack(alignment: .center) {
                Text("looks.title")
                    .font(DH.font(.display3))
                    .tracking(DH.tracking(.display3))
                    .foregroundStyle(DH.pinkDeep)
                    .accessibilityIdentifier("looks-library-title")

                Spacer(minLength: 0)
                StickerSparkle(size: 26, fill: DH.butter)
            }
        }
    }

    private var statsStrip: some View {
        HStack(spacing: 8) {
            statCard(
                value: "\(Looks.all.filter { !$0.isPro }.count)",
                label: L10n.string("looks.stats.free"),
                fill: .white,
                deep: DH.pinkLight,
                foreground: DH.pinkDeep
            )
            statCard(
                value: "\(viewModel?.favoritesCount ?? 0)",
                label: L10n.string("looks.stats.faves"),
                fill: DH.butter,
                deep: DH.butterDeep,
                foreground: DH.ink
            )
            statCard(
                value: "\(Looks.all.filter(\.isPro).count)",
                label: L10n.string("looks.stats.pro"),
                fill: DH.lavender,
                deep: DH.lavenderDeep,
                foreground: .white
            )
        }
    }

    private func statCard(value: String, label: String, fill: Color, deep: Color, foreground: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(DH.font(.headline))
                .tracking(DH.tracking(.headline))
                .foregroundStyle(foreground)
            Text(label)
                .font(DH.font(.microLabel))
                .tracking(DH.tracking(.microLabel))
                .foregroundStyle(foreground.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(fill, in: RoundedRectangle(cornerRadius: 18))
        .chunkyShadow(.sm(deep: deep), shape: RoundedRectangle(cornerRadius: 18))
    }

    private func lookCard(_ look: LookPreset, viewModel: LooksLibraryViewModel) -> some View {
        Button {
            selectedLook = look
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    lookThumbnail(look)
                        .frame(width: 140, height: 116)

                    favoriteButton(for: look, viewModel: viewModel)
                        .padding(8)

                    if look.isPro {
                        proBadge
                    }
                }

                cardFooter(for: look)
            }
            .frame(width: 140, height: 180, alignment: .top)
            .background(.white, in: RoundedRectangle(cornerRadius: 20))
            .chunkyShadow(.sm(deep: DH.pink), shape: RoundedRectangle(cornerRadius: 20))
            .overlay {
                if look.isPro {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(DH.butter.opacity(0.08))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func favoriteButton(for look: LookPreset, viewModel: LooksLibraryViewModel) -> some View {
        Button {
            viewModel.toggleFavorite(lookID: look.id)
        } label: {
            Image(systemName: viewModel.isFavorited(look.id) ? "heart.fill" : "heart")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(DH.pinkDeep)
                .frame(width: 32, height: 32)
                .background(.white.opacity(0.92), in: Circle())
        }
        .buttonStyle(.plain)
    }

    private func cardFooter(for look: LookPreset) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: look.localizedName)
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
                    .foregroundStyle(DH.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(
                    verbatim: look.isPro
                        ? (entitlements.isPro ? L10n.string("looks.card.pro") : L10n.string("looks.card.pro_locked"))
                        : L10n.string("looks.card.free")
                )
                    .font(DH.font(.microLabel))
                    .tracking(DH.tracking(.microLabel))
                    .foregroundStyle(DH.ink.opacity(0.58))
            }
            Spacer(minLength: 0)
        }
        .padding(12)
    }

    @ViewBuilder
    private func lookThumbnail(_ look: LookPreset) -> some View {
        AsyncBundleImage(assetName: look.thumbnailAsset, subdirectory: "Effects/thumbnails") {
            LinearGradient(
                colors: look.isPro ? [DH.lavender, DH.pinkLight] : [DH.pinkLight, DH.pinkPaper],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                VStack(spacing: 8) {
                    StickerSparkle(size: 22, fill: .white)
                    Text(verbatim: look.localizedName)
                        .font(DH.font(.microLabel))
                        .tracking(DH.tracking(.microLabel))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }
        }
        .scaledToFill()
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

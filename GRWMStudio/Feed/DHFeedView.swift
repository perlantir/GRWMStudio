import SwiftData
import SwiftUI

struct DHFeedView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appShellSelector) private var appShellSelector

    @State private var feedViewModel = FeedViewModel()
    @State private var looksViewModel: LooksLibraryViewModel?
    @State private var selectedLook: LookPreset?

    let onTryLook: @MainActor (LookPreset) -> Void

    private var debugFreezeLoading: Bool {
        DebugRuntimeFlags.contains("-GRWMDebugFreezeFeedLoading")
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [DH.pinkPaper, DH.cream], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    featuredRail

                    if debugFreezeLoading || feedViewModel.isLoading {
                        loadingState
                    } else if feedViewModel.items.isEmpty {
                        emptyState
                    } else if let looksViewModel {
                        FeedMosaic(
                            items: feedViewModel.items,
                            onTap: { item in
                                selectedLook = Looks.byID(item.lookID)
                            },
                            onHeart: { item in
                                looksViewModel.toggleFavorite(lookID: item.lookID)
                            },
                            isFavorited: { lookID in
                                looksViewModel.isFavorited(lookID)
                            }
                        )
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
            if looksViewModel == nil {
                looksViewModel = LooksLibraryViewModel(modelContext)
            }
            looksViewModel?.reloadFavorites()
            await feedViewModel.load()
        }
        .fullScreenCover(item: $selectedLook) { look in
            if let looksViewModel {
                LookDetailView(
                    look: look,
                    isFavorited: looksViewModel.isFavorited(look.id),
                    onToggleFavorite: {
                        looksViewModel.toggleFavorite(lookID: look.id)
                    },
                    onTryItOn: {
                        selectedLook = nil
                        onTryLook(look)
                        appShellSelector(.mirror)
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
            Text("feed.eyebrow")
                .font(DH.font(.microLabel))
                .tracking(DH.tracking(.microLabel))
                .foregroundStyle(DH.ink.opacity(0.56))

            HStack(alignment: .center) {
                Text("feed.title")
                    .font(DH.font(.display3))
                    .tracking(DH.tracking(.display3))
                    .foregroundStyle(DH.pinkDeep)

                Spacer(minLength: 0)
                StickerHeart(size: 22, fill: DH.pink)
            }
        }
    }

    private var featuredRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(feedViewModel.featuredItems) { item in
                    Button {
                        selectedLook = Looks.byID(item.lookID)
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(
                                        AngularGradient(
                                            colors: [DH.pink, DH.lavender, DH.butter, DH.pink],
                                            center: .center
                                        )
                                    )
                                    .frame(width: 68, height: 68)

                                Circle()
                                    .fill(item.palette.card)
                                    .frame(width: 58, height: 58)
                                    .overlay(Circle().stroke(.white, lineWidth: 2))
                                    .overlay {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 18, weight: .heavy))
                                            .foregroundStyle(item.palette.deep)
                                    }
                            }

                            Text(verbatim: item.localizedDisplayTitle.components(separatedBy: " ").first ?? item.localizedDisplayTitle)
                                .font(DH.font(.caption))
                                .tracking(dynamicTypeSize.isAccessibilitySize ? 0 : DH.tracking(.caption))
                                .foregroundStyle(DH.ink)
                                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                                .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.65 : 1)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: dynamicTypeSize.isAccessibilitySize ? 96 : 72)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L10n.format("feed.featured.accessibility_label", item.localizedDisplayTitle))
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var emptyState: some View {
        DHCard(bg: .white, deep: DH.pinkLight, cornerRadius: DH.Radius.card, padding: 22) {
            VStack(spacing: 14) {
                StickerSparkle(size: 30, fill: DH.butter)

                Text("feed.empty.title")
                    .font(DH.font(.headline))
                    .tracking(DH.tracking(.headline))
                    .foregroundStyle(DH.pinkDeep)

                Text("feed.empty.subtitle")
                    .font(DH.font(.body))
                    .tracking(DH.tracking(.body))
                    .foregroundStyle(DH.ink.opacity(0.68))
                    .multilineTextAlignment(.center)

                DHButton(title: L10n.string("common.try_again"), kind: .primary, size: .md) {
                    Task {
                        await feedViewModel.load()
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { index in
                HStack(spacing: 12) {
                    DHSkeleton(shape: AnyShape(RoundedRectangle(cornerRadius: 24)))
                        .frame(width: index.isMultiple(of: 2) ? 138 : 112, height: index.isMultiple(of: 2) ? 174 : 144)

                    VStack(spacing: 12) {
                        DHSkeleton(shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
                            .frame(height: index.isMultiple(of: 2) ? 82 : 110)
                        DHSkeleton(shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
                            .frame(height: index.isMultiple(of: 2) ? 110 : 82)
                    }
                }
            }
        }
        .padding(.top, 4)
    }
}

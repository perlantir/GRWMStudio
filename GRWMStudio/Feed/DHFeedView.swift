import SwiftData
import SwiftUI

struct DHFeedView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appShellSelector) private var appShellSelector

    @State private var feedViewModel: FeedViewModel?
    @State private var selectedCapture: SavedCapture?
    @State private var shareCapture: SavedCapture?
    @State private var pendingShareCapture: SavedCapture?

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

                    if debugFreezeLoading {
                        loadingState
                    } else if let feedViewModel {
                        dayRail(feedViewModel)

                        if feedViewModel.captures.isEmpty {
                            emptyState
                        } else if feedViewModel.visibleCaptures.isEmpty {
                            emptyDayState
                        } else {
                            FeedMosaic(
                                captures: feedViewModel.visibleCaptures,
                                captureURL: feedViewModel.captureURL,
                                metadata: feedViewModel.metadata,
                                onTap: { capture in
                                    selectedCapture = capture
                                },
                                onDelete: { capture in
                                    feedViewModel.delete(capture)
                                }
                            )
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
            if feedViewModel == nil {
                let viewModel = FeedViewModel(modelContext)
                await viewModel.load()
                feedViewModel = viewModel
                return
            }
            feedViewModel?.reload()
        }
        .onChange(of: selectedCapture) { _, newValue in
            guard newValue == nil, let pendingShareCapture else {
                return
            }

            shareCapture = pendingShareCapture
            self.pendingShareCapture = nil
        }
        .fullScreenCover(item: $selectedCapture) { capture in
            if let feedViewModel {
                LockerDetailView(
                    capture: capture,
                    url: feedViewModel.captureURL(capture),
                    onShare: {
                        pendingShareCapture = capture
                        selectedCapture = nil
                    },
                    onDelete: {
                        feedViewModel.delete(capture)
                        selectedCapture = nil
                    },
                    onDismiss: {
                        selectedCapture = nil
                    }
                )
            }
        }
        .fullScreenCover(item: $shareCapture) { capture in
            if let feedViewModel {
                SaveShareView(
                    capture: capture,
                    captureURL: feedViewModel.captureURL(capture),
                    onDone: {
                        shareCapture = nil
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

    private func dayRail(_ viewModel: FeedViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.dayBuckets) { day in
                    FeedDayButton(
                        day: day,
                        isAccessibilitySize: dynamicTypeSize.isAccessibilitySize
                    ) {
                        withAnimation(.snappy(duration: 0.22)) {
                            viewModel.selectDay(day)
                        }
                        DHHaptics.light()
                    }
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

                DHButton(title: L10n.string("feed.empty.cta"), kind: .primary, size: .md) {
                    appShellSelector(.mirror)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var emptyDayState: some View {
        DHCard(bg: DH.pinkPaper, deep: DH.pinkLight, cornerRadius: DH.Radius.card, padding: 18) {
            HStack(spacing: 12) {
                StickerStar(size: 24, fill: DH.butter)

                VStack(alignment: .leading, spacing: 3) {
                    Text("feed.day.empty.title")
                        .font(DH.font(.headline))
                        .tracking(DH.tracking(.headline))
                        .foregroundStyle(DH.pinkDeep)
                    Text("feed.day.empty.subtitle")
                        .font(DH.font(.body))
                        .tracking(DH.tracking(.body))
                        .foregroundStyle(DH.ink.opacity(0.68))
                }
            }
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

private struct FeedDayButton: View {
    let day: FeedDayBucket
    let isAccessibilitySize: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                bubble

                Text(verbatim: day.title)
                    .font(DH.font(.caption))
                    .tracking(isAccessibilitySize ? 0 : DH.tracking(.caption))
                    .foregroundStyle(day.isSelected ? DH.pinkDeep : DH.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .frame(width: isAccessibilitySize ? 96 : 72)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.format("feed.day.accessibility_label", day.title, day.captureTotal))
        .accessibilityValue(day.isSelected ? L10n.string("common.selected") : L10n.string("common.not_selected"))
    }

    private var bubble: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(
                    AngularGradient(
                        colors: day.isSelected
                            ? [DH.pink, DH.lavender, DH.butter, DH.pink]
                            : [DH.pinkLight, DH.pinkPaper, DH.butter, DH.pinkLight],
                        center: .center
                    )
                )
                .frame(width: 68, height: 68)

            Circle()
                .fill(day.isSelected ? DH.pink : .white)
                .frame(width: 58, height: 58)
                .overlay(Circle().stroke(.white, lineWidth: 2))
                .overlay {
                    Text("\(day.captureTotal)")
                        .font(DH.font(.headline))
                        .tracking(DH.tracking(.headline))
                        .foregroundStyle(day.isSelected ? .white : DH.pinkDeep)
                }

            if day.captureTotal > 0 {
                Circle()
                    .fill(DH.butter)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }
        }
    }
}

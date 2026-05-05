import SwiftUI

struct FeedMosaic: View {
    let items: [FeedItem]
    let onTap: (FeedItem) -> Void
    let onHeart: (FeedItem) -> Void
    let isFavorited: (String) -> Bool

    var body: some View {
        let columns = splitItems()

        HStack(alignment: .top, spacing: 12) {
            LazyVStack(spacing: 12) {
                ForEach(columns.left) { item in
                    card(for: item)
                }
            }

            LazyVStack(spacing: 12) {
                ForEach(columns.right) { item in
                    card(for: item)
                }
            }
            .padding(.top, 24)
        }
    }

    private func splitItems() -> (left: [FeedItem], right: [FeedItem]) {
        items.enumerated().reduce(into: ([FeedItem](), [FeedItem]())) { result, pair in
            if pair.offset.isMultiple(of: 2) {
                result.0.append(pair.element)
            } else {
                result.1.append(pair.element)
            }
        }
    }

    private func card(for item: FeedItem) -> some View {
        FeedCardView(
            item: item,
            favorited: isFavorited(item.lookID),
            onHeart: { onHeart(item) }
        )
        .onTapGesture { onTap(item) }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.format("feed.card.accessibility_label", item.localizedDisplayTitle, item.hearts))
        .accessibilityHint(L10n.string("feed.card.accessibility_hint"))
    }
}

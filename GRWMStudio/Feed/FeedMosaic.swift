import SwiftUI

struct FeedMosaic: View {
    let captures: [SavedCapture]
    let captureURL: (SavedCapture) -> URL
    let metadata: (SavedCapture) -> String
    let onTap: (SavedCapture) -> Void
    let onDelete: (SavedCapture) -> Void

    var body: some View {
        let columns = splitCaptures()

        HStack(alignment: .top, spacing: 12) {
            LazyVStack(spacing: 12) {
                ForEach(columns.left) { capture in
                    card(for: capture)
                }
            }

            LazyVStack(spacing: 12) {
                ForEach(columns.right) { capture in
                    card(for: capture)
                }
            }
            .padding(.top, 24)
        }
    }

    private func splitCaptures() -> (left: [SavedCapture], right: [SavedCapture]) {
        captures.enumerated().reduce(into: ([SavedCapture](), [SavedCapture]())) { result, pair in
            if pair.offset.isMultiple(of: 2) {
                result.0.append(pair.element)
            } else {
                result.1.append(pair.element)
            }
        }
    }

    private func card(for capture: SavedCapture) -> some View {
        FeedCardView(
            capture: capture,
            url: captureURL(capture),
            metadata: metadata(capture),
            onDelete: { onDelete(capture) }
        )
        .onTapGesture { onTap(capture) }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(capture.name)
        .accessibilityHint(L10n.string("feed.card.accessibility_hint"))
    }
}

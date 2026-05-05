import Foundation
import Observation

@MainActor
@Observable
final class FeedViewModel {
    private(set) var isLoading = false
    private(set) var items: [FeedItem] = []
    private(set) var featuredItems: [FeedItem] = []

    func load(minimumSkeletonDuration: Duration = .milliseconds(180)) async {
        isLoading = true
        let skeletonDuration = DebugRuntimeFlags.delay(
            minimumSkeletonDuration,
            slowFlag: "-GRWMDebugSlowLoadingStates"
        )

        async let loadedItems = Self.loadItemsFromBundle()
        try? await Task.sleep(for: skeletonDuration)

        let decoded = await loadedItems
        items = decoded
        featuredItems = decoded.filter(\.featured)
        isLoading = false
    }

    private static func loadItemsFromBundle() async -> [FeedItem] {
        if DebugRuntimeFlags.contains("-GRWMDebugEmptyFeed") {
            return []
        }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                guard
                    let url = Bundle.main.url(forResource: "feed-curated", withExtension: "json"),
                    let data = try? Data(contentsOf: url),
                    let decoded = try? JSONDecoder().decode([FeedItem].self, from: data)
                else {
                    continuation.resume(returning: [])
                    return
                }

                continuation.resume(returning: decoded)
            }
        }
    }
}

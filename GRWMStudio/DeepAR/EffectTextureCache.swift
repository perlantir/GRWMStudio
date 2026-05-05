import UIKit

@MainActor
final class EffectTextureCache {
    private var cache: [String: UIImage] = [:]
    private var lru: [String] = []
    private let limit: Int

    init(limit: Int = 12) {
        self.limit = limit
    }

    func image(for key: String, loader: @escaping () async -> UIImage?) async -> UIImage? {
        if let hit = cache[key] {
            touch(key)
            return hit
        }

        guard let image = await loader() else {
            return nil
        }

        cache[key] = image
        touch(key)
        trimIfNeeded()
        return image
    }

    func removeAll() {
        cache.removeAll()
        lru.removeAll()
    }

    var count: Int {
        cache.count
    }

    private func touch(_ key: String) {
        lru.removeAll { $0 == key }
        lru.append(key)
    }

    private func trimIfNeeded() {
        while lru.count > limit, let oldest = lru.first {
            cache.removeValue(forKey: oldest)
            lru.removeFirst()
        }
    }
}

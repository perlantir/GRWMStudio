import Foundation

enum GlowLevel {
    struct Info: Equatable {
        let level: Int
        let progressInLevel: Int
        let target: Int
    }

    static let capturesPerLevel = 5
    static let maxLevel = 99

    static func compute(captureCount: Int) -> Info {
        let clampedCount = max(captureCount, 0)
        let level = min(maxLevel, max(1, (clampedCount / capturesPerLevel) + 1))
        let progress = clampedCount % capturesPerLevel
        return Info(level: level, progressInLevel: progress, target: capturesPerLevel)
    }

    static func percent(captureCount: Int) -> Double {
        let info = compute(captureCount: captureCount)
        return Double(info.progressInLevel) / Double(info.target)
    }
}

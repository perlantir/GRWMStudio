import Foundation

@MainActor
enum StorageMonitor {
    static let recordThreshold: Int64 = 250 * 1_000_000
    static let saveThreshold: Int64 = 100 * 1_000_000

    static var availableBytes: Int64 {
        availableBytesProvider()
    }

    static var canRecord: Bool {
        availableBytes >= recordThreshold
    }

    static var canSave: Bool {
        availableBytes >= saveThreshold
    }

    static func setAvailableBytesProviderForTests(_ provider: @escaping @MainActor () -> Int64) {
        availableBytesProvider = provider
    }

    static func resetForTests() {
        availableBytesProvider = liveAvailableBytes
    }

    private static var availableBytesProvider: @MainActor () -> Int64 = liveAvailableBytes

    private static func liveAvailableBytes() -> Int64 {
        let url = URL(fileURLWithPath: NSHomeDirectory())
        let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        return values?.volumeAvailableCapacityForImportantUsage ?? 0
    }
}

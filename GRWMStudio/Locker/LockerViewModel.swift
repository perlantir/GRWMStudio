import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class LockerViewModel {
    private(set) var captures: [SavedCapture] = []
    private(set) var profile: ProfileRecord?
    private let modelContext: ModelContext

    init(_ modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func reload() {
        let descriptor = FetchDescriptor<SavedCapture>()
        let fetched = (try? modelContext.fetch(descriptor)) ?? []
        if DebugRuntimeFlags.contains("-GRWMDebugEmptyLocker") {
            captures = []
        } else {
            captures = fetched.sorted { $0.createdAt > $1.createdAt }
        }

        let profileDescriptor = FetchDescriptor<ProfileRecord>()
        if let storedProfile = try? modelContext.fetch(profileDescriptor).first {
            profile = storedProfile
        } else {
            let defaultProfile = ProfileRecord.makeDefault()
            modelContext.insert(defaultProfile)
            try? modelContext.save()
            profile = defaultProfile
        }
    }

    func delete(_ capture: SavedCapture) {
        let url = captureURL(capture)
        modelContext.delete(capture)
        try? modelContext.save()
        try? FileManager.default.removeItem(at: url)
        reload()
    }

    func captureURL(_ capture: SavedCapture) -> URL {
        URL.documentsCapturesURL.appendingPathComponent(capture.mediaPath)
    }

    var isAtLimit: Bool {
        captures.count >= 50
    }

    var displayName: String {
        profile?.displayName ?? L10n.string("profile.default_display_name")
    }

    var tagline: String {
        profile?.tagline ?? L10n.string("profile.default_tagline")
    }

    var avatarSwatch: AvatarSwatch {
        profile?.avatarSwatch ?? .pink
    }

    var looksTriedCount: Int {
        Set(captures.compactMap(\.appliedLookID)).count
    }

    var streakDays: Int {
        max(profile?.streakDays ?? 0, captures.isEmpty ? 0 : 1)
    }

    var glowLevel: Int {
        GlowLevel.compute(captureCount: captures.count).level
    }

    var glowLevelLabel: String {
        L10n.format("locker.profile.glow_level", "\(glowLevel)")
    }

    var glowProgressLabel: String {
        let progress = GlowLevel.compute(captureCount: captures.count)
        return L10n.format("locker.glow_progress", progress.progressInLevel, progress.target)
    }

    var glowPercent: Double {
        GlowLevel.percent(captureCount: captures.count)
    }
}

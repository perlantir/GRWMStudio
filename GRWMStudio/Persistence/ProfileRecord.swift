import CryptoKit
import Foundation
import SwiftData

@Model
final class SavedCapture {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var mediaPath: String
    var kindRaw: String
    var appliedLookID: String?
    var appliedShadesJSON: String
    var name: String
    var hearts: Int

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        mediaPath: String,
        kindRaw: String,
        appliedLookID: String? = nil,
        appliedShadesJSON: String = "{}",
        name: String,
        hearts: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.mediaPath = mediaPath
        self.kindRaw = kindRaw
        self.appliedLookID = appliedLookID
        self.appliedShadesJSON = appliedShadesJSON
        self.name = name
        self.hearts = hearts
    }

    var kind: Kind {
        Kind(rawValue: kindRaw) ?? .photo
    }

    enum Kind: String {
        case photo
        case video
    }
}

@Model
final class ProfileRecord {
    @Attribute(.unique) var id: UUID = UUID()
    var displayName: String
    var avatarKey: String
    var avatarSwatchRaw: String
    var tagline: String
    var proSince: Date?
    var proExpires: Date?
    var streakDays: Int
    var lifetimeHearts: Int
    var parentEmailHashed: String?
    var lastActiveDay: Date?
    var createdAt: Date

    init(
        displayName: String = "",
        avatarKey: String = "avatar_01",
        avatarSwatchRaw: String = AvatarSwatch.pink.rawValue,
        tagline: String = "",
        createdAt: Date = .now
    ) {
        self.displayName = displayName.isEmpty ? L10n.string("profile.default_display_name_short") : displayName
        self.avatarKey = avatarKey
        self.avatarSwatchRaw = avatarSwatchRaw
        self.tagline = tagline.isEmpty ? L10n.string("profile.default_tagline") : tagline
        self.streakDays = 0
        self.lifetimeHearts = 0
        self.createdAt = createdAt
    }

    static func normalizedParentEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func looksLikeParentEmail(_ email: String) -> Bool {
        let normalized = normalizedParentEmail(email)
        return normalized.contains("@") && normalized.contains(".") && normalized.count >= 5
    }

    static func parentEmailHash(for email: String) -> String? {
        let normalized = normalizedParentEmail(email)
        guard !normalized.isEmpty, looksLikeParentEmail(normalized) else {
            return nil
        }

        let hash = SHA256.hash(data: Data(normalized.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    var avatarSwatch: AvatarSwatch {
        get {
            if let swatch = AvatarSwatch(rawValue: avatarSwatchRaw) {
                return swatch
            }

            switch avatarKey {
            case "avatar_02":
                return .lavender
            case "avatar_03":
                return .butter
            case "avatar_04":
                return .mint
            case "avatar_05":
                return .peach
            default:
                return .pink
            }
        }
        set {
            avatarSwatchRaw = newValue.rawValue
        }
    }

    static func makeDefault() -> ProfileRecord {
        ProfileRecord(displayName: L10n.string("profile.default_display_name"))
    }

    func recordActivity(today: Date = .now) {
        let calendar = Calendar.current
        let normalizedToday = calendar.startOfDay(for: today)

        defer { lastActiveDay = normalizedToday }

        guard let lastActiveDay else {
            streakDays = 1
            return
        }

        let normalizedLastDay = calendar.startOfDay(for: lastActiveDay)
        guard let delta = calendar.dateComponents([.day], from: normalizedLastDay, to: normalizedToday).day else {
            streakDays = max(streakDays, 1)
            return
        }

        switch delta {
        case ..<0:
            streakDays = max(streakDays, 1)
        case 0:
            streakDays = max(streakDays, 1)
        case 1:
            streakDays = max(streakDays + 1, 2)
        default:
            streakDays = 1
        }
    }
}

@Model
final class FavoriteLook {
    @Attribute(.unique) var lookID: String
    var favoritedAt: Date

    init(lookID: String, favoritedAt: Date = .now) {
        self.lookID = lookID
        self.favoritedAt = favoritedAt
    }
}

enum AvatarSwatch: String, CaseIterable, Identifiable, Codable, Sendable {
    case pink
    case lavender
    case butter
    case mint
    case peach

    var id: String { rawValue }
}

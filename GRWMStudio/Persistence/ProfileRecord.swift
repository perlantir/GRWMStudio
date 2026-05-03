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
    var proSince: Date?
    var proExpires: Date?
    var streakDays: Int
    var lifetimeHearts: Int
    var parentEmailHashed: String?
    var createdAt: Date

    init(
        displayName: String = "Star",
        avatarKey: String = "avatar_01",
        createdAt: Date = .now
    ) {
        self.displayName = displayName
        self.avatarKey = avatarKey
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

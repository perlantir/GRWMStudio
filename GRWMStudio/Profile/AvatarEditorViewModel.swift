import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class AvatarEditorViewModel {
    var swatch: AvatarSwatch
    var displayName: String
    var tagline: String
    private(set) var validationShake = 0

    private let context: ModelContext
    private let record: ProfileRecord

    init(context: ModelContext, record: ProfileRecord) {
        self.context = context
        self.record = record
        swatch = record.avatarSwatch
        displayName = record.displayName
        tagline = record.tagline
    }

    func setDisplayName(_ value: String) {
        displayName = String(value.prefix(16))
    }

    func setTagline(_ value: String) {
        tagline = String(value.prefix(32))
    }

    func save() -> Bool {
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            validationShake &+= 1
            DHHaptics.shared.fire(.pop)
            return false
        }

        record.displayName = trimmedName
        let trimmedTagline = tagline.trimmingCharacters(in: .whitespacesAndNewlines)
        record.tagline = trimmedTagline.isEmpty ? L10n.string("profile.default_tagline") : trimmedTagline
        record.avatarSwatch = swatch

        do {
            try context.save()
            DHHaptics.shared.fire(.saved)
            Sounds.sparkle.play()
            NotificationCenter.default.post(name: .profileChanged, object: nil)
            return true
        } catch {
            validationShake &+= 1
            DHHaptics.shared.fire(.pop)
            return false
        }
    }
}

extension Notification.Name {
    static let profileChanged = Notification.Name("dh.profileChanged")
}

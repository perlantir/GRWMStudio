struct LookPreset: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let thumbnailAsset: String
    let effectID: EffectFile.ID
    let isPro: Bool

    var localizedName: String {
        L10n.string("\(id).name", fallback: name)
    }
}

enum Looks {
    static let all: [LookPreset] = [
        LookPreset(
            id: "look.sunday-best",
            name: "Sunday Best",
            thumbnailAsset: "look_legacy01",
            effectID: "look1",
            isPro: false
        ),
        LookPreset(
            id: "look.school-day",
            name: "School Day",
            thumbnailAsset: "look_legacy02",
            effectID: "look2",
            isPro: false
        )
    ]

    static func byID(_ id: String) -> LookPreset? {
        all.first(where: { $0.id == id })
    }
}

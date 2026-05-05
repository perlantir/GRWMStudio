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
        ),
        LookPreset(
            id: "look.birthday-glam",
            name: "Birthday Glam",
            thumbnailAsset: "look_thumb_bday",
            effectID: "look3",
            isPro: false
        ),
        LookPreset(
            id: "look.sleepover",
            name: "Sleepover",
            thumbnailAsset: "look_thumb_sleep",
            effectID: "look4",
            isPro: false
        ),
        LookPreset(
            id: "look.pop-star",
            name: "Pop Star",
            thumbnailAsset: "look_thumb_pop",
            effectID: "look_pro1",
            isPro: true
        ),
        LookPreset(
            id: "look.disco-princess",
            name: "Disco Princess",
            thumbnailAsset: "look_thumb_disco",
            effectID: "look_pro2",
            isPro: true
        ),
        LookPreset(
            id: "look.garden-party",
            name: "Garden Party",
            thumbnailAsset: "look_thumb_garden",
            effectID: "look_pro3",
            isPro: true
        ),
        LookPreset(
            id: "look.time-warp",
            name: "Time Warp",
            thumbnailAsset: "look_thumb_warp",
            effectID: "look_pro4",
            isPro: true
        )
    ]

    static func byID(_ id: String) -> LookPreset? {
        all.first(where: { $0.id == id })
    }
}

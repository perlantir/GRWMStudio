enum FilterCategory: String, CaseIterable, Identifiable, Sendable {
    case skin
    case base
    case eyes
    case brows
    case cheeks
    case lips
    case looks

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .skin:
            "Skin"
        case .base:
            "Base"
        case .eyes:
            "Eyes"
        case .brows:
            "Brows"
        case .cheeks:
            "Cheeks"
        case .lips:
            "Lips"
        case .looks:
            "Looks"
        }
    }

    var emoji: String {
        switch self {
        case .skin:
            "✨"
        case .base:
            "🪞"
        case .eyes:
            "👁️"
        case .brows:
            "🪞"
        case .cheeks:
            "🌸"
        case .lips:
            "💋"
        case .looks:
            "💖"
        }
    }

    var slot: EffectSlot {
        switch self {
        case .skin:
            .skin
        case .base:
            .base
        case .eyes:
            .eyes
        case .brows:
            .brows
        case .cheeks:
            .cheeks
        case .lips:
            .lips
        case .looks:
            .looks
        }
    }
}

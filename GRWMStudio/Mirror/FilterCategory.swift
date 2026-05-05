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
            L10n.string("mirror.category.skin")
        case .base:
            L10n.string("mirror.category.base")
        case .eyes:
            L10n.string("mirror.category.eyes")
        case .brows:
            L10n.string("mirror.category.brows")
        case .cheeks:
            L10n.string("mirror.category.cheeks")
        case .lips:
            L10n.string("mirror.category.lips")
        case .looks:
            L10n.string("mirror.category.looks")
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

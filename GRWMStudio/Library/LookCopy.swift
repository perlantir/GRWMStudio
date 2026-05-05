enum LookCopy {
    private static let compositionFallbacks: [String: [String]] = [
        "look.sunday-best": ["Soft shimmer lids", "Rosy cheeks", "Glossy pink lips"],
        "look.school-day": ["Clean liner", "Fresh glow base", "Peachy lip tint"],
        "look.birthday-glam": ["Sparkly shadow", "Candy blush", "Party lips"],
        "look.sleepover": ["Dreamy lilac lids", "Fluffy lashes", "Berry gloss"],
        "look.pop-star": ["Stage-bright shimmer", "Bold lashes", "Showtime lip color"],
        "look.disco-princess": ["Glitter wash lids", "Disco blush", "Berry satin lips"],
        "look.garden-party": ["Petal pink shadow", "Soft bloom cheeks", "Coral kiss lips"],
        "look.time-warp": ["Frosted shadow", "Graphic liner", "Gloss pop lips"],
        "look.default": ["Glowy base", "Sparkly eyes", "Sweet lip color"]
    ]

    static func description(for lookID: String) -> String {
        L10n.string("\(lookID).description", fallback: defaultDescription(for: lookID))
    }

    static func composition(for lookID: String) -> [String] {
        let key = compositionFallbacks[lookID] == nil ? "look.default" : lookID
        let fallbacks = compositionFallbacks[key] ?? []

        return fallbacks.enumerated().map { index, fallback in
            L10n.string("\(key).composition.\(index + 1)", fallback: fallback)
        }
    }

    private static func defaultDescription(for lookID: String) -> String {
        switch lookID {
        case "look.sunday-best":
            "A sweet everyday glow with soft sparkle and glossy lips."
        case "look.school-day":
            "A polished school-day combo with fresh cheeks and clean liner."
        case "look.birthday-glam":
            "A party-ready mix with shimmer, blush, and cake-day shine."
        case "look.sleepover":
            "A cozy-cute glam for pajamas, popcorn, and berry gloss."
        case "look.pop-star":
            "A big-stage pro look with bold lashes and bright spotlight energy."
        case "look.disco-princess":
            "A glitter-packed pro blend with berry lips and dance-floor sparkle."
        case "look.garden-party":
            "A floral pro look with petal tones and a soft sunshine glow."
        case "look.time-warp":
            "A retro-futuristic pro mix with frosted eyes and glossy drama."
        default:
            "A custom mix made just for your next mirror moment."
        }
    }
}

/// Top-level makeup categories shown in the mirror editor.
public enum MakeupCategory: String, CaseIterable, Identifiable, Sendable, Hashable {
    /// Skin smoothing and foundation options.
    case skin
    /// Base filters and LUT options.
    case base
    /// Eye makeup options.
    case eyes
    /// Brow makeup options.
    case brows
    /// Cheek and blush options.
    case cheeks
    /// Lip makeup options.
    case lips
    /// Preset complete looks.
    case looks

    /// Stable identifier used by SwiftUI lists and the effect manifest.
    public var id: String { rawValue }

    /// Child-friendly display label for the category.
    public var displayName: String {
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

    /// DeepAR slot used to load this category's effect.
    public var slot: EffectSlot {
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

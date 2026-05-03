// swiftlint:disable nesting

/// A selectable makeup shade in the effect manifest.
public struct MakeupShade: Decodable, Identifiable, Hashable, Sendable {
    /// Stable manifest identifier.
    public let id: String
    /// Display name shown to children.
    public let displayName: String
    /// Hex swatch color used by picker UI.
    public let color: String
    /// Whether the shade requires Studio Pro.
    public let isPro: Bool?
    /// Runtime parameter changes applied when the shade is selected.
    public let parameters: [ParameterChange]

    /// A single runtime parameter mutation declared by a manifest shade.
    public struct ParameterChange: Decodable, Hashable, Sendable {
        /// Supported runtime parameter mutation kinds.
        public enum Kind: String, Decodable, Sendable {
            /// RGBA color vector mutation.
            case color
            /// Texture asset mutation.
            case texture
            /// Float blendshape mutation.
            case blendshape
            /// Boolean enabled-state mutation.
            case bool
        }

        /// Parameter mutation kind.
        public let kind: Kind
        /// Ref key resolved by `EffectParameterMap`.
        public let ref: String
        /// RGBA color values for color mutations.
        public let rgba: [Double]?
        /// Asset catalog name for texture mutations.
        public let asset: String?
        /// Numeric value for blendshape or bool mutations.
        public let value: Double?
    }
}

// swiftlint:enable nesting

import Foundation

/// A shipped DeepAR effect entry from `Resources/Effects/manifest.json`.
public struct EffectFile: Decodable, Identifiable, Hashable, Sendable {
    /// Stable manifest identifier.
    public let id: String
    /// Display name shown to children.
    public let displayName: String
    /// Effect filename relative to `Resources/Effects`.
    public let file: String
    /// Thumbnail path relative to `Resources/Effects`.
    public let thumbnail: String
    /// Whether the effect requires Studio Pro.
    public let isPro: Bool
    /// Shade options available for this effect.
    public let shades: [MakeupShade]
    /// Optional short label used by preset looks.
    public let tag: String?
    /// Optional hot flag used by preset looks.
    public let hot: Bool?

    public var localizedDisplayName: String {
        L10n.string("deepar.effect.\(id).name", fallback: displayName)
    }

    /// Resolves the effect file in the application bundle.
    public func bundleURL() throws -> URL {
        let stem = (file as NSString).deletingPathExtension
        let ext = (file as NSString).pathExtension
        guard let url = Bundle.main.url(forResource: stem, withExtension: ext, subdirectory: "Effects") else {
            throw CatalogError.fileMissing(file)
        }
        return url
    }
}

/// Errors raised while loading or validating the shipped effect catalog.
public enum CatalogError: LocalizedError {
    /// The effect manifest was not found in the app bundle.
    case manifestMissing
    /// A referenced `.deepar` file was not found in the app bundle.
    case fileMissing(String)
    /// A manifest parameter ref does not resolve in `EffectParameterMap`.
    case unresolvedParameterRef(String)

    /// Human-readable error text for diagnostics.
    public var errorDescription: String? {
        switch self {
        case .manifestMissing:
            "Effect manifest is missing"
        case .fileMissing(let file):
            "Effect file is missing: \(file)"
        case .unresolvedParameterRef(let ref):
            "Effect parameter ref is unresolved: \(ref)"
        }
    }
}

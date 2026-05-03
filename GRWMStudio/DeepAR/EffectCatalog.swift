import Foundation

/// Loads and validates the shipped DeepAR effect manifest.
public actor EffectCatalog {
    /// Shared catalog used by app startup and mirror view models.
    public static let shared = EffectCatalog()
    private static let syncManifestSnapshot: ManifestRoot? = {
        guard let url = Bundle.main.url(forResource: "manifest", withExtension: "json", subdirectory: "Effects"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(ManifestRoot.self, from: data) else {
            return nil
        }
        return decoded
    }()

    private var cache: ManifestRoot?

    private init() {}

    /// Loads the production effect manifest once and returns the cached root on later calls.
    public func load() async throws -> ManifestRoot {
        if let cache {
            return cache
        }

        guard let url = Bundle.main.url(forResource: "manifest", withExtension: "json", subdirectory: "Effects") else {
            throw CatalogError.manifestMissing
        }

        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(ManifestRoot.self, from: data)
        try decoded.validate()
        cache = decoded
        return decoded
    }

    /// Returns effects for one makeup category.
    public func effects(for category: MakeupCategory) async throws -> [EffectFile] {
        try await load().effects[category.id] ?? []
    }

    /// Finds an effect by manifest identifier across every category.
    public func effect(byID id: EffectFile.ID) async throws -> EffectFile? {
        for effects in try await load().effects.values {
            if let match = effects.first(where: { $0.id == id }) {
                return match
            }
        }
        return nil
    }

    /// Synchronous manifest lookup for SwiftUI visibility decisions.
    public nonisolated func containsSync(effectID: EffectFile.ID) -> Bool {
        Self.syncManifestSnapshot?.contains(effectID: effectID) == true
    }
}

/// Top-level decoded manifest.
public struct ManifestRoot: Decodable, Sendable {
    /// Manifest schema version.
    public let version: Int
    /// Effects keyed by `MakeupCategory.id`.
    public let effects: [String: [EffectFile]]

    /// Validates manifest references that can be proven locally.
    public func validate() throws {
        for (_, list) in effects {
            for effect in list {
                for shade in effect.shades {
                    for parameter in shade.parameters where EffectParameterMap.resolve(parameter.ref) == nil {
                        throw CatalogError.unresolvedParameterRef(parameter.ref)
                    }
                }
            }
        }
    }

    /// Returns true when any category includes the requested effect identifier.
    public func contains(effectID: EffectFile.ID) -> Bool {
        effects.values.contains { list in
            list.contains { $0.id == effectID }
        }
    }
}

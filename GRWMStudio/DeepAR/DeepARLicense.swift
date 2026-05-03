import Foundation

enum DeepARLicense {
    enum LoadError: Error, Equatable {
        case missing
        case empty
    }

    static func key() throws -> String {
        try key(from: Bundle.main)
    }

    static func key(from bundle: Bundle) throws -> String {
        try key(from: bundle.infoDictionary ?? [:])
    }

    static func key(from infoDictionary: [String: Any]) throws -> String {
        guard let raw = infoDictionary["DEEPAR_LICENSE_KEY"] as? String else {
            throw LoadError.missing
        }

        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw LoadError.empty
        }
        return trimmed
    }
}

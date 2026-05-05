import Foundation

enum L10n {
    static func string(_ key: String) -> String {
        resolve(key, fallback: nil)
    }

    static func string(_ key: String, fallback: String) -> String {
        resolve(key, fallback: fallback)
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        resolveFormat(key, fallback: nil, arguments)
    }

    static func format(_ key: String, fallback: String, _ arguments: CVarArg...) -> String {
        resolveFormat(key, fallback: fallback, arguments)
    }

    static func plural(_ key: String, _ count: Int) -> String {
        resolvePlural(key, fallback: nil, count)
    }

    static func plural(_ key: String, fallback: String, _ count: Int) -> String {
        resolvePlural(key, fallback: fallback, count)
    }

    private static func resolve(_ key: String, fallback: String?) -> String {
        let localized = NSLocalizedString(key, comment: "")
        guard localized == key, let fallback else {
            return localized
        }
        return fallback
    }

    private static func resolveFormat(_ key: String, fallback: String?, _ arguments: [CVarArg]) -> String {
        let format = resolve(key, fallback: fallback)
        return String(format: format, locale: Locale.current, arguments: arguments)
    }

    private static func resolvePlural(_ key: String, fallback: String?, _ count: Int) -> String {
        String.localizedStringWithFormat(resolve(key, fallback: fallback), count)
    }
}

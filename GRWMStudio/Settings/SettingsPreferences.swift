import Foundation

enum SettingsPreferences {
    static let saveToPhotosKey = "dh.saveToPhotos"
    static let blockShareExtensionsKey = "dh.blockShareExtensions"
    static let soundEnabledKey = "dh.sound.enabled"
    static let hapticsEnabledKey = "dh.haptics.enabled"
    static let legacySoundsHapticsKey = "dh.soundsHaptics"

    static var saveToPhotos: Bool {
        get {
            UserDefaults.standard.object(forKey: saveToPhotosKey) as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: saveToPhotosKey)
        }
    }

    static var blockShareExtensions: Bool {
        get {
            UserDefaults.standard.object(forKey: blockShareExtensionsKey) as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: blockShareExtensionsKey)
        }
    }

    static var soundEnabled: Bool {
        get {
            bool(forKey: soundEnabledKey, fallbackKey: legacySoundsHapticsKey, defaultValue: true)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: soundEnabledKey)
        }
    }

    static var hapticsEnabled: Bool {
        get {
            bool(forKey: hapticsEnabledKey, fallbackKey: legacySoundsHapticsKey, defaultValue: true)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hapticsEnabledKey)
        }
    }

    static var soundsAndHaptics: Bool {
        get {
            soundEnabled && hapticsEnabled
        }
        set {
            soundEnabled = newValue
            hapticsEnabled = newValue
        }
    }

    private static func bool(forKey key: String, fallbackKey: String? = nil, defaultValue: Bool) -> Bool {
        let defaults = UserDefaults.standard

        if let value = defaults.object(forKey: key) as? Bool {
            return value
        }

        if let fallbackKey, let fallback = defaults.object(forKey: fallbackKey) as? Bool {
            return fallback
        }

        return defaultValue
    }
}

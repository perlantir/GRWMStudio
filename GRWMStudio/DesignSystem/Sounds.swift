import AudioToolbox

enum Sounds {
    static let shutter = SystemSound(id: 1108)
    static let countdownTick = SystemSound(id: 1057)
    static let confetti = SystemSound(id: 1025)
    static let bubble = SystemSound(id: 1157)
    static let sparkle = SystemSound(id: 1113)
    static let lockTap = SystemSound(id: 1156)
    static let fanfare = SystemSound(id: 1025)
}

struct SystemSound {
    let id: SystemSoundID

    func play() {
        guard SettingsPreferences.soundEnabled else {
            return
        }
        AudioServicesPlaySystemSound(id)
    }
}

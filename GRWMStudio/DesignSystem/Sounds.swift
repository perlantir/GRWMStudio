import AudioToolbox

enum Sounds {
    static let shutter = SystemSound(id: 1108)
    static let countdownTick = SystemSound(id: 1057)
    static let confetti = SystemSound(id: 1025)
}

struct SystemSound {
    let id: SystemSoundID

    func play() {
        AudioServicesPlaySystemSound(id)
    }
}

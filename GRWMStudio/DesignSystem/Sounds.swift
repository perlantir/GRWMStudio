import AudioToolbox

enum Sounds {
    static let shutter = SystemSound(id: 1108)
    static let countdownTick = SystemSound(id: 1057)
}

struct SystemSound {
    let id: SystemSoundID

    func play() {
        AudioServicesPlaySystemSound(id)
    }
}

import AudioToolbox

enum Sounds {
    static let shutter = SystemSound(id: 1108)
}

struct SystemSound {
    let id: SystemSoundID

    func play() {
        AudioServicesPlaySystemSound(id)
    }
}

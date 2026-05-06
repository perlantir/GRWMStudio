@MainActor
enum Sounds {
    static let shutter = AppSound(.shutter)
    static let countdownTick = AppSound(.countdownTick)
    static let countdownFinal = AppSound(.countdownFinal)
    static let recordStart = AppSound(.recordStart)
    static let recordStop = AppSound(.recordStop)
    static let errorSoft = AppSound(.errorSoft)
    static let confetti = AppSound(.saved)
    static let bubble = AppSound(.tapHard)
    static let sparkle = AppSound(.sparkle1)
    static let lockTap = AppSound(.tapSoft)
    static let fanfare = AppSound(.confettiPop)
}

@MainActor
struct AppSound {
    let sound: DHSound

    init(_ sound: DHSound) {
        self.sound = sound
    }

    func play() {
        DHAudio.shared.play(sound)
    }
}

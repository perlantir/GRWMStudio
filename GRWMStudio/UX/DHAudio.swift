import AVFoundation

enum DHSound: String, CaseIterable {
    case tapSoft
    case tapHard
    case shutter
    case countdownTick
    case countdownFinal
    case saved
    case recordStart
    case recordStop
    case errorSoft
    case lockerSwipe
    case lockerDelete
    case paywallReveal
    case sparkle1
    case sparkle2
    case sparkle3
    case confettiPop
    case swooshIn
    case swooshOut
    case heart
    case magic

    var url: URL? {
        Bundle.main.url(forResource: rawValue, withExtension: "mp3", subdirectory: "Audio")
            ?? Bundle.main.url(forResource: rawValue, withExtension: "mp3", subdirectory: "Resources/Audio")
            ?? Bundle.main.url(forResource: rawValue, withExtension: "mp3")
    }
}

@MainActor
final class DHAudio {
    static let shared = DHAudio()

    private var players: [DHSound: [AVAudioPlayer]] = [:]
    private let maxPlayersPerSound = 4
    private let volume: Float = 0.6

    private init() {
        configureSession()
        preload([.tapSoft, .tapHard, .shutter, .lockerSwipe, .magic])
    }

    func play(_ sound: DHSound) {
        guard SettingsPreferences.soundEnabled, let player = player(for: sound) else {
            return
        }

        player.currentTime = 0
        player.volume = volume
        player.play()
    }

    func preload(_ sounds: [DHSound]) {
        sounds.forEach { _ = player(for: $0) }
    }

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return
        }
    }

    private func player(for sound: DHSound) -> AVAudioPlayer? {
        if let available = players[sound]?.first(where: { !$0.isPlaying }) {
            return available
        }

        if (players[sound]?.count ?? 0) < maxPlayersPerSound, let newPlayer = makePlayer(for: sound) {
            players[sound, default: []].append(newPlayer)
            return newPlayer
        }

        guard let recycled = players[sound]?.first else {
            return nil
        }
        recycled.stop()
        return recycled
    }

    private func makePlayer(for sound: DHSound) -> AVAudioPlayer? {
        guard let url = sound.url else {
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            return player
        } catch {
            return nil
        }
    }
}

import Foundation
import AVFoundation

enum BuzzMode: String, CaseIterable, Identifiable {
    case classic = "Classic Buzz"
    case turbo = "Turbo Buzz"
    case cartoon = "Cartoon Buzz"
    case robot = "Robot Trimmer"

    var id: String { rawValue }

    /// Placeholder file names. Add original sound assets to your Xcode target.
    /// Example location: BuzzSnap/Sounds/
    var fileName: String {
        switch self {
        case .classic: return "classic_buzz"
        case .turbo: return "turbo_buzz"
        case .cartoon: return "cartoon_buzz"
        case .robot: return "robot_trimmer"
        }
    }
}

final class AudioManager: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var volume: Float = 0.8 {
        didSet { player?.volume = volume }
    }

    private var player: AVAudioPlayer?

    override init() {
        super.init()
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    func start(mode: BuzzMode) {
        guard let url = Bundle.main.url(forResource: mode.fileName, withExtension: "mp3") else {
            print("Missing placeholder sound: \(mode.fileName).mp3")
            isPlaying = false
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = volume
            player?.play()
            isPlaying = true
        } catch {
            print("Failed to play audio: \(error)")
            isPlaying = false
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
    }

    func toggle(mode: BuzzMode) {
        isPlaying ? stop() : start(mode: mode)
    }

    func restartIfNeeded(mode: BuzzMode) {
        guard isPlaying else { return }
        stop()
        start(mode: mode)
    }
}

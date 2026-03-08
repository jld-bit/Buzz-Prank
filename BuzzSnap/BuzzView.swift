import SwiftUI
import AVFoundation
import CoreHaptics

struct BuzzView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var favoritesManager = FavoritesManager()

    @Binding var flashlightEnabled: Bool
    @Binding var vibrationEnabled: Bool

    @State private var selectedMode: BuzzMode = .classic
    @State private var showFavoritesOnly = false
    @State private var hapticsEngine: CHHapticEngine?

    var displayModes: [BuzzMode] {
        showFavoritesOnly
            ? BuzzMode.allCases.filter { favoritesManager.isFavorite($0) }
            : BuzzMode.allCases
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("BuzzSnap")
                .font(.largeTitle.bold())
                .padding(.top, 12)

            Spacer(minLength: 10)

            Button(action: toggleBuzz) {
                Text(audioManager.isPlaying ? "STOP" : "BUZZ")
                    .font(.largeTitle.bold())
                    .frame(width: 220, height: 220)
                    .background(audioManager.isPlaying ? Color.red : Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Modes")
                    .font(.headline)

                if displayModes.isEmpty {
                    Text("No favorites selected yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(displayModes) { mode in
                                modeButton(for: mode)
                            }
                        }
                    }
                }
            }

            Toggle("Flashlight Toggle", isOn: $flashlightEnabled)
                .onChange(of: flashlightEnabled) { _, enabled in
                    if !enabled { setTorch(enabled: false) }
                }

            Toggle("Vibration Toggle", isOn: $vibrationEnabled)

            VStack(alignment: .leading) {
                Text("Volume")
                    .font(.headline)
                Slider(value: Binding(
                    get: { Double(audioManager.volume) },
                    set: { audioManager.volume = Float($0) }
                ), in: 0...1)
            }

            Button(showFavoritesOnly ? "Show All Modes" : "Favorites Mode") {
                showFavoritesOnly.toggle()
                if showFavoritesOnly,
                   !displayModes.contains(selectedMode),
                   let firstFavorite = displayModes.first {
                    selectedMode = firstFavorite
                    audioManager.restartIfNeeded(mode: selectedMode)
                }
            }
            .buttonStyle(.borderedProminent)

            Spacer(minLength: 10)

            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 56)
                .overlay(Text("Banner Ad").foregroundStyle(.secondary))
        }
        .padding()
        .onAppear(perform: prepareHaptics)
    }

    @ViewBuilder
    private func modeButton(for mode: BuzzMode) -> some View {
        VStack(spacing: 6) {
            Button(mode.rawValue) {
                selectedMode = mode
                audioManager.restartIfNeeded(mode: selectedMode)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selectedMode == mode ? Color.blue : Color.gray.opacity(0.2))
            .foregroundStyle(selectedMode == mode ? .white : .primary)
            .clipShape(Capsule())

            Button(favoritesManager.isFavorite(mode) ? "★" : "☆") {
                favoritesManager.toggle(mode)
            }
            .buttonStyle(.plain)
        }
    }

    private func toggleBuzz() {
        audioManager.toggle(mode: selectedMode)

        if audioManager.isPlaying {
            if flashlightEnabled { setTorch(enabled: true) }
            if vibrationEnabled { playHapticPulse() }
        } else {
            setTorch(enabled: false)
        }
    }

    private func setTorch(enabled: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            if enabled {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch control failed: \(error)")
        }
    }

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            hapticsEngine = try CHHapticEngine()
            try hapticsEngine?.start()
        } catch {
            print("Haptics engine failed: \(error)")
        }
    }

    private func playHapticPulse() {
        guard vibrationEnabled,
              CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticsEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
}

#Preview {
    BuzzView(flashlightEnabled: .constant(false), vibrationEnabled: .constant(true))
}

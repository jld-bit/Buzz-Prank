import SwiftUI

struct SettingsView: View {
    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer = false
    @Binding var flashlightEnabled: Bool
    @Binding var vibrationEnabled: Bool

    var body: some View {
        Form {
            Section("Playback") {
                Toggle("Flashlight", isOn: $flashlightEnabled)
                Toggle("Vibration", isOn: $vibrationEnabled)
            }

            Section("Safety") {
                Button("Show Entertainment Notice Again") {
                    hasAcceptedDisclaimer = false
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            flashlightEnabled: .constant(true),
            vibrationEnabled: .constant(true)
        )
    }
}

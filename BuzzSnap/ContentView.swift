import SwiftUI

struct ContentView: View {
    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer = false
    @State private var flashlightEnabled = false
    @State private var vibrationEnabled = true

    var body: some View {
        NavigationStack {
            BuzzView(
                flashlightEnabled: $flashlightEnabled,
                vibrationEnabled: $vibrationEnabled
            )
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                NavigationLink("Settings") {
                    SettingsView(
                        flashlightEnabled: $flashlightEnabled,
                        vibrationEnabled: $vibrationEnabled
                    )
                }
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { !hasAcceptedDisclaimer },
            set: { _ in }
        )) {
            DisclaimerView {
                hasAcceptedDisclaimer = true
            }
        }
    }
}

#Preview {
    ContentView()
}

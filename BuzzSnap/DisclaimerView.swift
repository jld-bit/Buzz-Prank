import SwiftUI

struct DisclaimerView: View {
    let onAcknowledge: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Entertainment Notice")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("This app is for entertainment purposes only.\nDo not use this app to harass, scare, or disturb others.\nThe developer is not responsible for misuse of this application.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button(action: onAcknowledge) {
                Text("I Understand")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    DisclaimerView(onAcknowledge: {})
}

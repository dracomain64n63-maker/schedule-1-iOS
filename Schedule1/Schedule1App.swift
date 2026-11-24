
import SwiftUI

@main
struct Schedule1App: App {
    @State private var showSettings = false
    @State private var startGame = false

    var body: some Scene {
        WindowGroup {
            Group {
                if showSettings {
                    SettingsView {
                        showSettings = false
                    }
                } else {
                    MainMenuView(
                        onPlay: {
                            startGame = true
                        },
                        onSettings: {
                            showSettings = true
                        }
                    )
                }
            }
            .preferredColorScheme(.dark)
            .fullScreenCover(isPresented: $startGame) {
                GameView()
            }
        }
    }
}

private struct SettingsView: View {
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("SETTINGS")
                    .font(.system(size: 28, weight: .bold))
                    .tracking(3)

                VStack(alignment: .leading, spacing: 14) {
                    Text("CONTROLS")
                        .font(.headline)

                    Text("Touch Controls")
                    Text("• Use the directional pad to move.")
                    Text("• Drag across the screen to look around.")
                    Text("• Tap INTERACT to interact with objects.")

                    Divider()

                    Text("CONTROLLER")
                        .font(.headline)

                    Text("• Left stick: Move")
                    Text("• Right stick: Look around")
                    Text("• A: Interact")
                    Text("• Menu: Pause")
                }
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .padding(20)
                .frame(maxWidth: 420, alignment: .leading)
                .background(.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Button(action: onBack) {
                    Text("BACK")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(2)
                        .frame(maxWidth: 220)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(24)
        }
    }
}

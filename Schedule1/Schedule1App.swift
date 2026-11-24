import SwiftUI

@main
struct Schedule1App: App {
    @State private var showSettings = false
    @State private var startGame = false

    var body: some Scene {
        WindowGroup {
            MainMenuView(
                onPlay: { startGame = true },
                onSettings: { showSettings = true }
            )
            .preferredColorScheme(.dark)
            .fullScreenCover(isPresented: $startGame) {
                GameView()
            }
            .sheet(isPresented: $showSettings) {
                GameSettingsView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}

private struct GameSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("lookSensitivity") private var lookSensitivity = 0.0022
    @AppStorage("moveSpeed") private var moveSpeed = 3.2
    @AppStorage("joystickScale") private var joystickScale = 1.0
    @AppStorage("showTouchControls") private var showTouchControls = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Camera") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Look sensitivity")
                            Spacer()
                            Text(String(format: "%.4f", lookSensitivity))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $lookSensitivity, in: 0.0008...0.006, step: 0.0002)
                    }
                }

                Section("Movement") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Movement speed")
                            Spacer()
                            Text(String(format: "%.1f", moveSpeed))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $moveSpeed, in: 1.5...7.0, step: 0.1)
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Joystick size")
                            Spacer()
                            Text("\(Int(joystickScale * 100))%")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $joystickScale, in: 0.7...1.5, step: 0.05)
                    }
                    Toggle("Show touch controls", isOn: $showTouchControls)
                }

                Section {
                    Button("Reset settings") {
                        lookSensitivity = 0.0022
                        moveSpeed = 3.2
                        joystickScale = 1.0
                        showTouchControls = true
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

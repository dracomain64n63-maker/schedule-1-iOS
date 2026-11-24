import SwiftUI

@main
struct Schedule1App: App {
    @State private var showSettings = false
    @State private var startGame = false

    var body: some Scene {
        WindowGroup {
            Group {
                if startGame {
                    ContentView()
                } else if showSettings {
                    SettingsView()
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
        }
    }
}

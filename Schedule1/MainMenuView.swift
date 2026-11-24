import SwiftUI

struct MainMenuView: View {
    @State private var showGame = false
    @State private var showSettings = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.035, green: 0.045, blue: 0.055),
                         Color(red: 0.12, green: 0.14, blue: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Text("SCHEDULE 1")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .tracking(3)

                Text("BUILD YOUR BUSINESS")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .tracking(3)
                    .foregroundStyle(.white.opacity(0.62))
                    .padding(.top, 8)

                Spacer()

                VStack(spacing: 12) {
                    menuButton("PLAY") { showGame = true }
                    menuButton("SETTINGS") { showSettings = true }
                }
                .padding(.bottom, 46)
            }
            .padding(.horizontal, 28)
        }
        .fullScreenCover(isPresented: $showGame) {
            GameView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationDetents([.medium])
        }
    }

    private func menuButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .tracking(2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(.white.opacity(title == "PLAY" ? 0.18 : 0.08))
                .overlay(Rectangle().stroke(.white.opacity(0.22), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("Prototype settings")
                    .font(.headline)
                Text("Difficulty and control customization are not implemented in this prototype.")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

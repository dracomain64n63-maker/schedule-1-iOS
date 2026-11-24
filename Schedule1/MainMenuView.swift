import SwiftUI

struct MainMenuView: View {
    var onPlay: () -> Void
    var onSettings: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.08, blue: 0.07),
                    Color(red: 0.015, green: 0.02, blue: 0.02)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Text("SCHEDULE")
                    .font(.system(size: 58, weight: .black, design: .default))
                    .tracking(3)
                    .foregroundColor(.white)

                Text("1")
                    .font(.system(size: 58, weight: .black))
                    .foregroundColor(.green)

                Text("YOUR CITY. YOUR RULES.")
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(4)
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.top, 8)

                Spacer()

                VStack(alignment: .leading, spacing: 14) {
                    menuButton("PLAY", action: onPlay)

                    menuButton("SETTINGS", action: onSettings)

                    Text("VERSION 1.0")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.35))
                        .padding(.top, 20)
                }

                Spacer()
                    .frame(height: 35)
            }
            .padding(.horizontal, 35)
            .padding(.vertical, 30)
        }
        .preferredColorScheme(.dark)
    }

    private func menuButton(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .tracking(2)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .frame(height: 58)
            .background(Color.white.opacity(0.08))
            .overlay(
                Rectangle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainMenuView(
        onPlay: {},
        onSettings: {}
    )
}

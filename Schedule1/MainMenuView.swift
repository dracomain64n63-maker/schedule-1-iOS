import SwiftUI
import RealityKit
import UIKit

struct MainMenuView: View {
    var onPlay: () -> Void
    var onSettings: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                MenuRVScene()
                    .ignoresSafeArea()

                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.94), location: 0),
                        .init(color: .black.opacity(0.78), location: 0.34),
                        .init(color: .black.opacity(0.20), location: 0.72),
                        .init(color: .black.opacity(0.42), location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text("SCHEDULE  1")
                        .font(.system(size: 27, weight: .black, design: .serif))
                        .tracking(1.2)
                        .foregroundStyle(.white)
                    Text("v0.3.1.1")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.58))
                        .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 0) {
                        menuItem("Continue", action: onPlay)
                        menuItem("New Game", action: onPlay)
                        menuItem("Settings", action: onSettings)
                        menuItem("Credits", action: {})
                        menuItem("Quit", action: {})
                    }
                    .padding(.top, 10)

                    Spacer()
                    HStack {
                        Text("SELECT")
                        Text("BACK")
                    }
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.55))
                }
                .padding(.leading, max(20, proxy.size.width * 0.035))
                .padding(.top, 24)
                .padding(.bottom, 20)
                .frame(width: min(230, proxy.size.width * 0.43), alignment: .leading)

                VStack {
                    HStack {
                        Spacer()
                        Text("Lobby (1/4)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "gamecontroller.fill")
                        Image(systemName: "xmark")
                        Image(systemName: "person.2.fill")
                        Image(systemName: "pause.rectangle")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.75))
                }
                .padding(18)
                .allowsHitTesting(false)
            }
            .background(Color.black)
        }
        .preferredColorScheme(.dark)
    }

    private func menuItem(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 5)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct MenuRVScene: View {
    var body: some View {
        RealityView { content in
            let root = Entity()
            let camera = PerspectiveCamera()
            camera.position = [8.4, 4.2, 10.8]
            camera.look(at: [0, 1.4, 0], from: camera.position, relativeTo: nil)
            root.addChild(camera)

            let light = DirectionalLight()
            light.light.intensity = 8500
            light.orientation = simd_quatf(angle: -.pi / 3, axis: [1, 0, 0])
            root.addChild(light)

            let body = ModelEntity(mesh: .generateBox(size: [3.4, 2.8, 6.5]),
                                   materials: [SimpleMaterial(color: UIColor(red: 0.78, green: 0.79, blue: 0.73, alpha: 1), roughness: .float(0.75), isMetallic: false)])
            body.position = [0, 1.55, 0]
            root.addChild(body)

            let stripe = ModelEntity(mesh: .generateBox(size: [3.44, 0.62, 6.55]),
                                     materials: [SimpleMaterial(color: UIColor(red: 0.08, green: 0.34, blue: 0.17, alpha: 1), roughness: .float(0.8), isMetallic: false)])
            stripe.position = [0, 0.75, 0]
            root.addChild(stripe)

            for z: Float in [-2.0, -0.55, 0.95] {
                let window = ModelEntity(mesh: .generateBox(size: [0.08, 1.1, 1.0]),
                                         materials: [SimpleMaterial(color: UIColor(red: 0.025, green: 0.04, blue: 0.055, alpha: 1), roughness: .float(0.15), isMetallic: true)])
                window.position = [1.75, 2.0, z]
                root.addChild(window)
            }

            let doorFrame = ModelEntity(mesh: .generateBox(size: [0.09, 2.35, 1.25]),
                                        materials: [SimpleMaterial(color: UIColor(white: 0.12, alpha: 1), roughness: .float(0.25), isMetallic: true)])
            doorFrame.position = [1.76, 1.55, 2.35]
            root.addChild(doorFrame)

            let door = ModelEntity(mesh: .generateBox(size: [0.035, 2.18, 1.08]),
                                   materials: [SimpleMaterial(color: UIColor(red: 0.48, green: 0.035, blue: 0.34, alpha: 1), roughness: .float(0.2), isMetallic: true)])
            door.position = [1.82, 1.55, 2.35]
            root.addChild(door)

            for z: Float in [-2.0, 2.0] {
                let wheel = ModelEntity(mesh: .generateCylinder(height: 0.34, radius: 0.58),
                                        materials: [SimpleMaterial(color: UIColor(white: 0.045, alpha: 1), roughness: .float(0.95), isMetallic: false)])
                wheel.position = [1.72, 0.55, z]
                wheel.orientation = simd_quatf(angle: .pi / 2, axis: [0, 0, 1])
                root.addChild(wheel)
            }

            let step1 = ModelEntity(mesh: .generateBox(size: [1.3, 0.12, 0.55]),
                                    materials: [SimpleMaterial(color: UIColor(white: 0.22, alpha: 1), roughness: .float(0.8), isMetallic: true)])
            step1.position = [1.8, 0.35, 2.65]
            root.addChild(step1)
            let step2 = ModelEntity(mesh: .generateBox(size: [1.3, 0.12, 0.55]),
                                    materials: [SimpleMaterial(color: UIColor(white: 0.28, alpha: 1), roughness: .float(0.8), isMetallic: true)])
            step2.position = [1.8, 0.12, 3.1]
            root.addChild(step2)

            let pink = PointLight()
            pink.light.color = UIColor(red: 1, green: 0.03, blue: 0.58, alpha: 1)
            pink.light.intensity = 2300
            pink.light.attenuationRadius = 7
            pink.position = [1.1, 2.1, 2.0]
            root.addChild(pink)

            let ground = ModelEntity(mesh: .generateBox(size: [80, 0.2, 80]),
                                     materials: [SimpleMaterial(color: UIColor(red: 0.045, green: 0.05, blue: 0.05, alpha: 1), roughness: .float(1), isMetallic: false)])
            ground.position = [0, -0.15, 0]
            root.addChild(ground)

            content.add(root)
        }
    }
}

#Preview {
    MainMenuView(onPlay: {}, onSettings: {})
}

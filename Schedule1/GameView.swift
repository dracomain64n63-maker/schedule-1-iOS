import SwiftUI
import RealityKit
import simd
import GameController

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var playerPosition = SIMD3<Float>(0, 1.6, 5)
    @State private var yaw: Float = 0
    @State private var pitch: Float = 0
    @State private var cash = 250
    @State private var message = "Explore the block. Tap the marked property to interact."
    @State private var showTouchControls = true
    @State private var controllerConnected = false

    var body: some View {
        ZStack {
            CityScene(
                playerPosition: playerPosition,
                yaw: yaw,
                pitch: pitch,
                onPropertyTap: buyProperty
            )
            .ignoresSafeArea()
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { value in
                        yaw -= Float(value.translation.width - value.startLocation.x) * 0.0015
                        pitch = max(-0.65, min(0.65, pitch - Float(value.translation.height - value.startLocation.y) * 0.001))
                    }
            )

            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SCHEDULE 1")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .tracking(2)
                        Text("$\(cash)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "pause.fill")
                            .font(.headline)
                            .padding(12)
                            .background(.black.opacity(0.55), in: Circle())
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)

                Spacer()

                Text(message)
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.black.opacity(0.65), in: Capsule())
                    .padding(.bottom, 14)

                if showTouchControls {
                    HStack(spacing: 22) {
                        movementPad
                        Spacer()
                        Button {
                            interact()
                        } label: {
                            Text("INTERACT")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(1)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 16)
                                .background(.white.opacity(0.2), in: Capsule())
                                .overlay(Capsule().stroke(.white.opacity(0.5), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .statusBarHidden()
        .onAppear(perform: detectController)
    }

    private var movementPad: some View {
        VStack(spacing: 5) {
            moveButton("arrow.up", x: 0, z: -1)
            HStack(spacing: 5) {
                moveButton("arrow.left", x: -1, z: 0)
                moveButton("arrow.down", x: 0, z: 1)
                moveButton("arrow.right", x: 1, z: 0)
            }
        }
    }

    private func moveButton(_ symbol: String, x: Float, z: Float) -> some View {
        Button {
            let forward = SIMD3<Float>(-sin(yaw), 0, -cos(yaw))
            let right = SIMD3<Float>(cos(yaw), 0, -sin(yaw))
            playerPosition += (right * x + forward * z) * 0.45
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .frame(width: 42, height: 42)
                .background(.black.opacity(0.6), in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func detectController() {
        controllerConnected = !GCController.controllers().isEmpty
        showTouchControls = !controllerConnected
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { _ in
            controllerConnected = true
            showTouchControls = false
        }
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil,
            queue: .main
        ) { _ in
            controllerConnected = false
            showTouchControls = true
        }
    }

    private func buyProperty() {
        message = "Property selected. Use INTERACT to inspect it."
    }

    private func interact() {
        if cash >= 200 {
            cash -= 200
            message = "You acquired the starter property. Business systems are coming later."
        } else {
            message = "Not enough cash to acquire this property."
        }
    }
}

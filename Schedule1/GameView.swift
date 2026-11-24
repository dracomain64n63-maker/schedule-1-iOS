import SwiftUI
import RealityKit
import simd
import GameController
import QuartzCore

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var playerPosition = SIMD3<Float>(0, 1.6, 5)
    @State private var yaw: Float = 0
    @State private var pitch: Float = 0
    @State private var cash = 250
    @State private var message = "Explore the neighborhood. Find the green-and-white RV."
    @State private var showTouchControls = true
    @State private var controllerConnected = false
    @State private var lastDragTranslation = CGSize.zero
    @State private var activeController: GCController?
    @State private var observerTokens: [NSObjectProtocol] = []
    @State private var lastControllerInputTime = CACurrentMediaTime()
    @State private var hasAcquiredProperty = false

    private let touchLookSensitivity: Float = 0.0022
    private let controllerLookSensitivity: Float = 1.8
    private let movementSpeed: Float = 3.2

    var body: some View {
        ZStack {
            CityScene(playerPosition: playerPosition, yaw: yaw, pitch: pitch)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 2)
                        .onChanged { value in
                            let dx = value.translation.width - lastDragTranslation.width
                            let dy = value.translation.height - lastDragTranslation.height
                            lastDragTranslation = value.translation
                            yaw -= Float(dx) * touchLookSensitivity
                            pitch = max(-0.85, min(0.85, pitch - Float(dy) * touchLookSensitivity))
                        }
                        .onEnded { _ in lastDragTranslation = .zero }
                )

            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SCHEDULE 1")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .tracking(2)
                        Text("$\(cash)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    if controllerConnected {
                        Label("CONTROLLER", systemImage: "gamecontroller.fill")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .padding(9)
                            .background(.black.opacity(0.55), in: Capsule())
                    }
                    Button { dismiss() } label: {
                        Image(systemName: "pause.fill")
                            .font(.headline)
                            .padding(12)
                            .background(.black.opacity(0.6), in: Circle())
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)

                Spacer()

                Text(message)
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.black.opacity(0.7), in: Capsule())
                    .padding(.bottom, 12)

                if showTouchControls {
                    HStack(alignment: .bottom) {
                        movementPad
                        Spacer()
                        Button(action: interact) {
                            Text("INTERACT")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(1)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 17)
                                .background(.black.opacity(0.68), in: Capsule())
                                .overlay(Capsule().stroke(.white.opacity(0.5), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 22)
                }
            }
        }
        .statusBarHidden()
        .onAppear(perform: configureController)
        .onDisappear(perform: disconnectControllerHandlers)
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
            movePlayer(strafe: x, forward: -z, duration: 0.22)
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .frame(width: 44, height: 44)
                .background(.black.opacity(0.65), in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func movePlayer(strafe: Float, forward: Float, duration: Float) {
        let forwardVector = SIMD3<Float>(-sin(yaw), 0, -cos(yaw))
        let rightVector = SIMD3<Float>(cos(yaw), 0, -sin(yaw))
        let direction = rightVector * strafe + forwardVector * forward
        let length = simd_length(direction)
        guard length > 0 else { return }
        playerPosition += (direction / length) * movementSpeed * duration
    }

    private func configureController() {
        GCController.shouldMonitorBackgroundEvents = true
        let connectedToken = NotificationCenter.default.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { notification in
            guard let controller = notification.object as? GCController else { return }
            attach(controller)
        }
        let disconnectedToken = NotificationCenter.default.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { notification in
            guard let disconnected = notification.object as? GCController else { return }
            if activeController === disconnected {
                activeController = nil
                controllerConnected = false
                showTouchControls = true
                message = "Controller disconnected. Touch controls restored."
            }
        }
        observerTokens = [connectedToken, disconnectedToken]
        if let controller = GCController.controllers().first {
            attach(controller)
        }
    }

    private func attach(_ controller: GCController) {
        guard let gamepad = controller.extendedGamepad else {
            message = "This controller profile isn't supported. Use an Xbox, PlayStation, or MFi controller with a standard gamepad layout."
            return
        }
        activeController = controller
        controllerConnected = true
        showTouchControls = false
        lastControllerInputTime = CACurrentMediaTime()
        gamepad.valueChangedHandler = { pad, _ in
            let now = CACurrentMediaTime()
            let delta = Float(min(0.05, max(0.001, now - lastControllerInputTime)))
            lastControllerInputTime = now
            DispatchQueue.main.async {
                let leftX = pad.leftThumbstick.xAxis.value
                let leftY = pad.leftThumbstick.yAxis.value
                let rightX = pad.rightThumbstick.xAxis.value
                let rightY = pad.rightThumbstick.yAxis.value
                let deadZone: Float = 0.13
                let lx = abs(leftX) > deadZone ? leftX : 0
                let ly = abs(leftY) > deadZone ? leftY : 0
                let rx = abs(rightX) > deadZone ? rightX : 0
                let ry = abs(rightY) > deadZone ? rightY : 0
                if lx != 0 || ly != 0 {
                    movePlayer(strafe: lx, forward: ly, duration: delta)
                }
                yaw -= rx * controllerLookSensitivity * delta
                pitch = max(-0.85, min(0.85, pitch + ry * controllerLookSensitivity * delta))
            }
        }
        gamepad.buttonA.pressedChangedHandler = { _, _, pressed in
            if pressed { DispatchQueue.main.async { interact() } }
        }
        gamepad.buttonMenu.pressedChangedHandler = { _, _, pressed in
            if pressed { DispatchQueue.main.async { dismiss() } }
        }
        message = "Controller connected. Left stick: move · Right stick: look · A: interact · Menu: pause."
    }

    private func disconnectControllerHandlers() {
        activeController?.extendedGamepad?.valueChangedHandler = nil
        activeController?.extendedGamepad?.buttonA.pressedChangedHandler = nil
        activeController?.extendedGamepad?.buttonMenu.pressedChangedHandler = nil
        observerTokens.forEach(NotificationCenter.default.removeObserver)
        observerTokens.removeAll()
    }

    private func interact() {
        guard !hasAcquiredProperty else {
            message = "This property is already yours. More activities will be added later."
            return
        }
        if cash >= 200 {
            cash -= 200
            hasAcquiredProperty = true
            message = "Starter property acquired. This is a visual prototype; business systems aren't implemented yet."
        } else {
            message = "Not enough cash to acquire the starter property."
        }
    }
}

import SwiftUI
import RealityKit
import simd
import GameController
import QuartzCore

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("lookSensitivity") private var lookSensitivity = 0.0022
    @AppStorage("moveSpeed") private var moveSpeedSetting = 3.2
    @AppStorage("joystickScale") private var joystickScale = 1.0
    @AppStorage("showTouchControls") private var showTouchControlsSetting = true

    @State private var playerPosition = SIMD3<Float>(0, 1.6, 5)
    @State private var yaw: Float = 0
    @State private var pitch: Float = 0
    @State private var cash = 250
    @State private var message = "Explore the neighborhood. Find the green-and-white RV."
    @State private var controllerConnected = false
    @State private var lastDragTranslation = CGSize.zero
    @State private var joystickVector = CGSize.zero
    @State private var activeController: GCController?
    @State private var observerTokens: [NSObjectProtocol] = []
    @State private var lastControllerInputTime = CACurrentMediaTime()
    @State private var hasAcquiredProperty = false

    private var movementSpeed: Float { Float(moveSpeedSetting) }
    private var touchLookSensitivity: Float { Float(lookSensitivity) }
    private let controllerLookSensitivity: Float = 1.65

    var body: some View {
        ZStack {
            CityScene(playerPosition: playerPosition, yaw: yaw, pitch: pitch)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 3)
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

                if showTouchControlsSetting && !controllerConnected {
                    HStack(alignment: .bottom) {
                        VirtualJoystick(scale: joystickScale) { vector in
                            joystickVector = vector
                            movePlayer(strafe: Float(vector.width), forward: Float(-vector.height), duration: 0.035)
                        }
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

    private func movePlayer(strafe: Float, forward: Float, duration: Float) {
        let fwd = SIMD3<Float>(-sin(yaw), 0, -cos(yaw))
        let right = SIMD3<Float>(cos(yaw), 0, -sin(yaw))
        let direction = right * strafe + fwd * forward
        let length = simd_length(direction)
        guard length > 0.001 else { return }
        playerPosition += (direction / length) * movementSpeed * duration
    }

    private func configureController() {
        GCController.shouldMonitorBackgroundEvents = true
        let connected = NotificationCenter.default.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { notification in
            guard let controller = notification.object as? GCController else { return }
            attach(controller)
        }
        let disconnected = NotificationCenter.default.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { notification in
            guard let controller = notification.object as? GCController else { return }
            if activeController === controller {
                activeController = nil
                controllerConnected = false
                message = "Controller disconnected. Touch controls restored."
            }
        }
        observerTokens = [connected, disconnected]
        if let controller = GCController.controllers().first { attach(controller) }
    }

    private func attach(_ controller: GCController) {
        guard let pad = controller.extendedGamepad else {
            message = "This controller profile is not supported."
            return
        }
        activeController = controller
        controllerConnected = true
        lastControllerInputTime = CACurrentMediaTime()
        pad.valueChangedHandler = { gamepad, _ in
            let now = CACurrentMediaTime()
            let delta = Float(min(0.05, max(0.001, now - lastControllerInputTime)))
            lastControllerInputTime = now
            DispatchQueue.main.async {
                let dead: Float = 0.13
                let x = abs(gamepad.leftThumbstick.xAxis.value) > dead ? gamepad.leftThumbstick.xAxis.value : 0
                let y = abs(gamepad.leftThumbstick.yAxis.value) > dead ? gamepad.leftThumbstick.yAxis.value : 0
                let rx = abs(gamepad.rightThumbstick.xAxis.value) > dead ? gamepad.rightThumbstick.xAxis.value : 0
                let ry = abs(gamepad.rightThumbstick.yAxis.value) > dead ? gamepad.rightThumbstick.yAxis.value : 0
                if x != 0 || y != 0 { movePlayer(strafe: x, forward: y, duration: delta) }
                yaw -= rx * controllerLookSensitivity * delta
                pitch = max(-0.85, min(0.85, pitch + ry * controllerLookSensitivity * delta))
            }
        }
        pad.buttonA.pressedChangedHandler = { _, _, pressed in
            if pressed { DispatchQueue.main.async { interact() } }
        }
        pad.buttonMenu.pressedChangedHandler = { _, _, pressed in
            if pressed { DispatchQueue.main.async { dismiss() } }
        }
        message = "Controller connected. Left stick: move · Right stick: look · A: interact."
    }

    private func disconnectControllerHandlers() {
        activeController?.extendedGamepad?.valueChangedHandler = nil
        activeController?.extendedGamepad?.buttonA.pressedChangedHandler = nil
        activeController?.extendedGamepad?.buttonMenu.pressedChangedHandler = nil
        observerTokens.forEach { NotificationCenter.default.removeObserver($0) }
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
            message = "Starter property acquired. Business systems are not implemented yet."
        } else {
            message = "Not enough cash to acquire the starter property."
        }
    }
}

private struct VirtualJoystick: View {
    let scale: Double
    let onMove: (CGSize) -> Void
    @State private var knob = CGSize.zero
    private let baseSize: CGFloat = 132
    private var size: CGFloat { baseSize * CGFloat(min(1.5, max(0.7, scale))) }

    var body: some View {
        ZStack {
            Circle()
                .fill(.black.opacity(0.48))
                .overlay(Circle().stroke(.white.opacity(0.38), lineWidth: 1.5))
                .frame(width: size, height: size)
            Circle()
                .fill(.white.opacity(0.18))
                .overlay(Circle().stroke(.white.opacity(0.65), lineWidth: 1))
                .frame(width: size * 0.39, height: size * 0.39)
                .offset(knob)
        }
        .frame(width: size, height: size)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let radius = size * 0.34
                    let x = value.translation.width
                    let y = value.translation.height
                    let length = sqrt(x * x + y * y)
                    let factor = length > radius ? radius / length : 1
                    knob = CGSize(width: x * factor, height: y * factor)
                    onMove(CGSize(width: knob.width / radius, height: knob.height / radius))
                }
                .onEnded { _ in
                    knob = .zero
                    onMove(.zero)
                }
        )
    }
}

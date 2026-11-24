import SwiftUI
import RealityKit
import simd
import UIKit

struct CityScene: View {
    let playerPosition: SIMD3<Float>
    let yaw: Float
    let pitch: Float
    let onPropertyTap: () -> Void

    var body: some View {
        RealityView { content in
            let root = Entity()

            let camera = PerspectiveCamera()
            camera.name = "PlayerCamera"
            camera.position = playerPosition
            camera.orientation = simd_quatf(angle: yaw, axis: [0, 1, 0])
                * simd_quatf(angle: pitch, axis: [1, 0, 0])
            root.addChild(camera)

            let sunlight = DirectionalLight()
            sunlight.light.intensity = 12000
            sunlight.orientation = simd_quatf(angle: -.pi / 4, axis: [1, 0, 0])
            root.addChild(sunlight)

            let ground = ModelEntity(
                mesh: .generatePlane(width: 80, depth: 80),
                materials: [SimpleMaterial(color: UIColor(white: 0.16, alpha: 1), roughness: 1, isMetallic: false)]
            )
            ground.position = [0, 0, 0]
            root.addChild(ground)

            addBuilding(to: root, position: [-5, 2.5, -8], size: [5, 5, 5], color: .darkGray)
            addBuilding(to: root, position: [4, 3.5, -10], size: [6, 7, 5], color: .gray)
            addBuilding(to: root, position: [-10, 2, 1], size: [4, 4, 5], color: .brown)
            addBuilding(to: root, position: [10, 2.5, 0], size: [5, 5, 5], color: .darkGray)

            let property = ModelEntity(
                mesh: .generateBox(size: [2.8, 2.4, 2.8]),
                materials: [SimpleMaterial(color: .systemGreen, roughness: 0.8, isMetallic: false)]
            )
            property.name = "StarterProperty"
            property.position = [0, 1.2, -7]
            root.addChild(property)

            content.add(root)
        } update: { content in
            guard let root = content.entities.first,
                  let camera = root.findEntity(named: "PlayerCamera") as? PerspectiveCamera else { return }
            camera.position = playerPosition
            camera.orientation = simd_quatf(angle: yaw, axis: [0, 1, 0])
                * simd_quatf(angle: pitch, axis: [1, 0, 0])
        }
        .overlay(alignment: .center) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(.white.opacity(0.75))
                .allowsHitTesting(false)
        }
    }

    private func addBuilding(to root: Entity, position: SIMD3<Float>, size: SIMD3<Float>, color: UIColor) {
        let building = ModelEntity(
            mesh: .generateBox(size: size),
            materials: [SimpleMaterial(color: color, roughness: 0.95, isMetallic: false)]
        )
        building.position = position
        root.addChild(building)
    }
}

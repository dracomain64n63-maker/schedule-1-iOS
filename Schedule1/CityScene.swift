import SwiftUI
import RealityKit
import simd
import UIKit

struct CityScene: View {
    let playerPosition: SIMD3<Float>
    let yaw: Float
    let pitch: Float

    var body: some View {
        RealityView { content in
            let world = Entity()
            world.name = "World"

            let camera = PerspectiveCamera()
            camera.name = "PlayerCamera"
            camera.position = playerPosition
            camera.fieldOfViewInDegrees = 78
            world.addChild(camera)

            let sun = DirectionalLight()
            sun.light.intensity = 9500
            sun.orientation = simd_quatf(angle: -.pi / 3.2, axis: [1, 0, 0])
            world.addChild(sun)

            let fill = PointLight()
            fill.light.intensity = 1800
            fill.light.attenuationRadius = 32
            fill.position = [0, 8, 2]
            world.addChild(fill)

            buildStreet(in: world)
            buildBuildings(in: world)
            buildStreetFurniture(in: world)
            buildStarterProperty(in: world)

            content.add(world)
        } update: { content in
            guard let world = content.entities.first,
                  let camera = world.findEntity(named: "PlayerCamera") as? PerspectiveCamera else { return }
            camera.position = playerPosition
            camera.orientation = simd_quatf(angle: yaw, axis: [0, 1, 0])
                * simd_quatf(angle: pitch, axis: [1, 0, 0])
        }
        .overlay {
            Image(systemName: "plus")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(.white.opacity(0.8))
                .shadow(color: .black, radius: 3)
                .allowsHitTesting(false)
        }
    }

    private func material(_ color: UIColor, roughness: Float = 0.88, metal: Bool = false) -> SimpleMaterial {
        SimpleMaterial(color: color, roughness: roughness, isMetallic: metal)
    }

    private func addBox(_ parent: Entity, name: String = "", position: SIMD3<Float>, size: SIMD3<Float>, color: UIColor, roughness: Float = 0.88, metal: Bool = false) -> ModelEntity {
        let entity = ModelEntity(mesh: .generateBox(size: size), materials: [material(color, roughness: roughness, metal: metal)])
        entity.position = position
        entity.name = name
        parent.addChild(entity)
        return entity
    }

    private func buildStreet(in root: Entity) {
        addBox(root, name: "Asphalt", position: [0, -0.12, -5], size: [34, 0.2, 70], color: UIColor(red: 0.16, green: 0.18, blue: 0.19, alpha: 1), roughness: 1)
        addBox(root, name: "LeftSidewalk", position: [-8.5, 0.02, -5], size: [3, 0.28, 70], color: UIColor(white: 0.42, alpha: 1))
        addBox(root, name: "RightSidewalk", position: [8.5, 0.02, -5], size: [3, 0.28, 70], color: UIColor(white: 0.42, alpha: 1))

        for z in stride(from: 27.0, through: -39.0, by: -6.0) {
            addBox(root, position: [0, 0.005, Float(z)], size: [0.13, 0.025, 2.8], color: UIColor(red: 0.82, green: 0.79, blue: 0.65, alpha: 1))
        }
        for side: Float in [-1, 1] {
            addBox(root, position: [side * 7.0, 0.03, -5], size: [0.12, 0.04, 70], color: UIColor(white: 0.78, alpha: 1))
        }
    }

    private func buildBuildings(in root: Entity) {
        // Left storefront: laundromat-inspired neighborhood shop.
        storefront(root, x: -12, z: -5, width: 7, height: 5.2, depth: 9,
                   wall: UIColor(red: 0.23, green: 0.29, blue: 0.32, alpha: 1), sign: "LAUNDROMAT",
                   accent: UIColor(red: 0.55, green: 0.76, blue: 0.78, alpha: 1))
        storefront(root, x: 12, z: -4, width: 8, height: 6.2, depth: 10,
                   wall: UIColor(red: 0.48, green: 0.25, blue: 0.19, alpha: 1), sign: "CORNER SHOP",
                   accent: UIColor(red: 0.88, green: 0.38, blue: 0.24, alpha: 1))

        apartment(root, x: -13, z: -20, color: UIColor(red: 0.39, green: 0.35, blue: 0.30, alpha: 1), height: 10)
        apartment(root, x: 13, z: -21, color: UIColor(red: 0.34, green: 0.38, blue: 0.40, alpha: 1), height: 12)
        apartment(root, x: -13, z: 12, color: UIColor(red: 0.40, green: 0.31, blue: 0.27, alpha: 1), height: 8)
        apartment(root, x: 13, z: 13, color: UIColor(red: 0.34, green: 0.35, blue: 0.31, alpha: 1), height: 9)

        // A small, recognizable green-and-white RV based on the supplied visual reference.
        let rv = Entity()
        rv.position = [-2.8, 0.15, -13]
        root.addChild(rv)
        addBox(rv, position: [0, 1.55, 0], size: [3.2, 2.8, 6.2], color: UIColor(red: 0.78, green: 0.79, blue: 0.73, alpha: 1))
        addBox(rv, position: [0, 0.72, 0], size: [3.24, 0.62, 6.22], color: UIColor(red: 0.12, green: 0.38, blue: 0.20, alpha: 1))
        addBox(rv, position: [0, 3.0, 0], size: [3.1, 0.12, 6.1], color: UIColor(white: 0.19, alpha: 1))
        for z: Float in [-1.9, -0.35, 1.25] {
            addBox(rv, position: [1.63, 1.85, z], size: [0.035, 1.15, 0.92], color: UIColor(red: 0.08, green: 0.12, blue: 0.17, alpha: 1), metal: true)
        }
        addBox(rv, position: [1.67, 1.5, 2.55], size: [0.06, 2.25, 1.15], color: UIColor(red: 0.65, green: 0.12, blue: 0.52, alpha: 1), roughness: 0.25, metal: true)
        for z: Float in [-2.1, 2.1] {
            let wheel = ModelEntity(mesh: .generateCylinder(height: 0.34, radius: 0.58), materials: [material(UIColor(white: 0.08, alpha: 1), roughness: 0.95)])
            wheel.position = [1.63, 0.58, z]
            wheel.orientation = simd_quatf(angle: .pi / 2, axis: [0, 0, 1])
            rv.addChild(wheel)
        }
    }

    private func storefront(_ root: Entity, x: Float, z: Float, width: Float, height: Float, depth: Float, wall: UIColor, sign: String, accent: UIColor) {
        let shop = Entity()
        shop.position = [x, 0, z]
        root.addChild(shop)
        addBox(shop, position: [0, height / 2, 0], size: [width, height, depth], color: wall)
        addBox(shop, position: [0, height + 0.18, 0], size: [width + 0.25, 0.25, depth + 0.25], color: UIColor(white: 0.12, alpha: 1))
        addBox(shop, position: [0, height - 0.65, depth / 2 + 0.04], size: [width - 0.7, 0.75, 0.12], color: accent, roughness: 0.5)
        addBox(shop, position: [0, 1.8, depth / 2 + 0.08], size: [width - 0.8, 2.0, 0.08], color: UIColor(red: 0.10, green: 0.17, blue: 0.20, alpha: 1), roughness: 0.2, metal: true)
        addBox(shop, position: [0, 1.8, depth / 2 + 0.14], size: [0.10, 2.05, 0.06], color: UIColor(white: 0.55, alpha: 1), metal: true)
        addBox(shop, position: [-width * 0.31, 1.8, depth / 2 + 0.14], size: [0.08, 2.05, 0.06], color: UIColor(white: 0.55, alpha: 1), metal: true)
        addBox(shop, position: [width * 0.31, 1.8, depth / 2 + 0.14], size: [0.08, 2.05, 0.06], color: UIColor(white: 0.55, alpha: 1), metal: true)
        // Sign panel and raised lettering bars make each shop read clearly from the street.
        addBox(shop, position: [0, height + 0.65, depth / 2 + 0.16], size: [width - 0.5, 0.58, 0.12], color: UIColor(white: 0.08, alpha: 1))
        let barCount = max(5, min(12, sign.count))
        for i in 0..<barCount {
            let px = -width * 0.34 + Float(i) * (width * 0.68 / Float(max(1, barCount - 1)))
            addBox(shop, position: [px, height + 0.66, depth / 2 + 0.24], size: [0.12, 0.24, 0.035], color: accent, roughness: 0.35)
        }
    }

    private func apartment(_ root: Entity, x: Float, z: Float, color: UIColor, height: Float) {
        let building = Entity()
        building.position = [x, 0, z]
        root.addChild(building)
        addBox(building, position: [0, height / 2, 0], size: [7.2, height, 8.5], color: color)
        addBox(building, position: [0, height + 0.15, 0], size: [7.5, 0.3, 8.8], color: UIColor(white: 0.16, alpha: 1))
        let floors = max(2, Int(height / 2.4))
        for floor in 0..<floors {
            let y = 1.5 + Float(floor) * 2.25
            for col in 0..<3 {
                let px = -2.2 + Float(col) * 2.2
                addBox(building, position: [px, y, 4.28], size: [1.05, 1.15, 0.09], color: UIColor(red: 0.10, green: 0.16, blue: 0.20, alpha: 1), roughness: 0.2, metal: true)
                addBox(building, position: [px, y, 4.34], size: [1.12, 0.07, 0.08], color: UIColor(white: 0.62, alpha: 1))
            }
        }
    }

    private func buildStreetFurniture(in root: Entity) {
        for z: Float in [-25, -8, 9, 25] {
            for x: Float in [-8.9, 8.9] {
                addBox(root, position: [x, 2.7, z], size: [0.12, 5.4, 0.12], color: UIColor(white: 0.12, alpha: 1), metal: true)
                addBox(root, position: [x, 5.35, z], size: [0.75, 0.18, 0.75], color: UIColor(red: 0.85, green: 0.72, blue: 0.48, alpha: 1), roughness: 0.35)
            }
        }
        for z: Float in [-17, 2, 20] {
            let trunk = addBox(root, position: [-7.2, 1.4, z], size: [0.35, 2.8, 0.35], color: UIColor(red: 0.28, green: 0.19, blue: 0.12, alpha: 1))
            _ = trunk
            let leaves = ModelEntity(mesh: .generateCone(height: 3.2, radius: 1.25), materials: [material(UIColor(red: 0.12, green: 0.34, blue: 0.20, alpha: 1))])
            leaves.position = [-7.2, 3.5, z]
            root.addChild(leaves)
        }
    }

    private func buildStarterProperty(in root: Entity) {
        let property = Entity()
        property.name = "StarterProperty"
        property.position = [0, 0, -30]
        root.addChild(property)
        addBox(property, position: [0, 1.7, 0], size: [8.5, 3.4, 7], color: UIColor(red: 0.34, green: 0.38, blue: 0.35, alpha: 1))
        addBox(property, position: [0, 3.55, 0], size: [8.9, 0.3, 7.4], color: UIColor(white: 0.13, alpha: 1))
        addBox(property, position: [0, 1.45, 3.56], size: [1.5, 2.9, 0.12], color: UIColor(red: 0.12, green: 0.20, blue: 0.22, alpha: 1), roughness: 0.25, metal: true)
        addBox(property, position: [-2.4, 2.0, 3.56], size: [1.4, 1.4, 0.12], color: UIColor(red: 0.10, green: 0.16, blue: 0.18, alpha: 1), roughness: 0.2, metal: true)
    }
}

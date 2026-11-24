
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
            camera.camera.fieldOfViewInDegrees = 72
            camera.position = playerPosition
            world.addChild(camera)

            let sun = DirectionalLight()
            sun.light.intensity = 11000
            sun.orientation = simd_quatf(angle: -.pi / 3.4, axis: [1, 0, 0])
            world.addChild(sun)

            let ambient = PointLight()
            ambient.light.intensity = 2200
            ambient.light.attenuationRadius = 42
            ambient.position = [0, 12, 2]
            world.addChild(ambient)

            buildRoad(in: world)
            buildCity(in: world)
            buildRV(in: world, position: [-3.0, 0.0, -13.0])
            buildStreetDetails(in: world)
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
                .foregroundStyle(.white.opacity(0.82))
                .shadow(color: .black, radius: 3)
                .allowsHitTesting(false)
        }
    }

    private func mat(_ color: UIColor, roughness: Float = 0.82, metal: Bool = false) -> SimpleMaterial {
        SimpleMaterial(color: color, roughness: .float(roughness), isMetallic: metal)
    }

    @discardableResult
    private func box(_ parent: Entity, _ name: String = "", _ p: SIMD3<Float>,
                     _ s: SIMD3<Float>, _ c: UIColor, rough: Float = 0.82,
                     metal: Bool = false) -> ModelEntity {
        let e = ModelEntity(mesh: .generateBox(size: s), materials: [mat(c, roughness: rough, metal: metal)])
        e.name = name
        e.position = p
        parent.addChild(e)
        return e
    }

    private func cylinder(_ parent: Entity, _ p: SIMD3<Float>, radius: Float, height: Float,
                          color: UIColor, rotation: simd_quatf = simd_quatf()) {
        let e = ModelEntity(mesh: .generateCylinder(height: height, radius: radius),
                            materials: [mat(color, roughness: 0.9)])
        e.position = p
        e.orientation = rotation
        parent.addChild(e)
    }

    private func buildRoad(in root: Entity) {
        box(root, "Road", [0, -0.14, -8], [34, 0.24, 82], UIColor(red: 0.105, green: 0.12, blue: 0.13, alpha: 1), rough: 1)
        box(root, "LeftWalk", [-9.4, 0.0, -8], [3.0, 0.28, 82], UIColor(red: 0.42, green: 0.42, blue: 0.39, alpha: 1))
        box(root, "RightWalk", [9.4, 0.0, -8], [3.0, 0.28, 82], UIColor(red: 0.42, green: 0.42, blue: 0.39, alpha: 1))

        for z in stride(from: 30.0, through: -48.0, by: -6.0) {
            box(root, "", [0, 0.012, Float(z)], [0.13, 0.025, 2.8], UIColor(red: 0.86, green: 0.82, blue: 0.68, alpha: 1))
        }

        for side: Float in [-1, 1] {
            box(root, "", [side * 7.7, 0.03, -8], [0.12, 0.05, 82], UIColor(white: 0.76, alpha: 1))
        }

        for i in 0..<7 {
            box(root, "", [-3.6 + Float(i) * 1.2, 0.015, -1.5], [0.72, 0.025, 3.4], UIColor(white: 0.78, alpha: 1))
        }
    }

    private func buildCity(in root: Entity) {
        storefront(root, x: -12.0, z: -5.0, width: 7.0, height: 5.6, depth: 9.0,
                   wall: UIColor(red: 0.20, green: 0.27, blue: 0.30, alpha: 1),
                   sign: "LAUNDROMAT", accent: UIColor(red: 0.32, green: 0.68, blue: 0.72, alpha: 1))

        storefront(root, x: 12.0, z: -4.0, width: 8.0, height: 6.0, depth: 10.0,
                   wall: UIColor(red: 0.39, green: 0.20, blue: 0.17, alpha: 1),
                   sign: "CORNER SHOP", accent: UIColor(red: 0.88, green: 0.30, blue: 0.20, alpha: 1))

        apartment(root, x: -13, z: -22, height: 12, floors: 4,
                  color: UIColor(red: 0.36, green: 0.32, blue: 0.28, alpha: 1))

        apartment(root, x: 13, z: -22, height: 14, floors: 5,
                  color: UIColor(red: 0.31, green: 0.35, blue: 0.37, alpha: 1))

        apartment(root, x: -13, z: 13, height: 9, floors: 3,
                  color: UIColor(red: 0.40, green: 0.29, blue: 0.24, alpha: 1))

        apartment(root, x: 13, z: 14, height: 11, floors: 4,
                  color: UIColor(red: 0.32, green: 0.34, blue: 0.30, alpha: 1))

        apartment(root, x: -14, z: -40, height: 16, floors: 6,
                  color: UIColor(red: 0.34, green: 0.35, blue: 0.36, alpha: 1))

        apartment(root, x: 14, z: -41, height: 15, floors: 5,
                  color: UIColor(red: 0.42, green: 0.34, blue: 0.28, alpha: 1))
    }

    private func storefront(_ root: Entity, x: Float, z: Float, width: Float, height: Float,
                            depth: Float, wall: UIColor, sign: String, accent: UIColor) {
        let shop = Entity()
        shop.position = [x, 0, z]
        root.addChild(shop)

        box(shop, "ShopBody", [0, height / 2, 0], [width, height, depth], wall)

        box(shop, "", [0, height + 0.18, 0], [width + 0.25, 0.30, depth + 0.25], UIColor(white: 0.10, alpha: 1))

        box(shop, "", [0, 1.85, depth / 2 + 0.07], [width - 0.55, 2.35, 0.09],
            UIColor(red: 0.055, green: 0.105, blue: 0.13, alpha: 1), rough: 0.2, metal: true)

        for px in [-width * 0.28, 0, width * 0.28] {
            box(shop, "", [px, 1.85, depth / 2 + 0.14], [0.075, 2.38, 0.08], UIColor(white: 0.56, alpha: 1), metal: true)
        }

        box(shop, "", [0, height - 0.42, depth / 2 + 0.12], [width - 0.25, 0.75, 0.16], accent, rough: 0.45)

        box(shop, "", [0, height + 0.72, depth / 2 + 0.15], [width - 0.35, 0.72, 0.14], UIColor(white: 0.055, alpha: 1))

        add3DText(sign, parent: shop, position: [-width * 0.38, height + 0.52, depth / 2 + 0.24],
                  size: 0.34, color: .white)

        box(shop, "", [width * 0.31, 1.55, depth / 2 + 0.20], [0.045, 0.55, 0.045], UIColor(white: 0.8, alpha: 1), metal: true)
    }

    private func apartment(_ root: Entity, x: Float, z: Float, height: Float, floors: Int, color: UIColor) {
        let b = Entity()
        b.position = [x, 0, z]
        root.addChild(b)

        box(b, "", [0, height / 2, 0], [7.4, height, 8.5], color)
        box(b, "", [0, height + 0.16, 0], [7.7, 0.32, 8.8], UIColor(white: 0.13, alpha: 1))

        for floor in 0..<floors {
            let y = 1.45 + Float(floor) * (height / Float(floors))

            for col in 0..<3 {
                let xw = -2.25 + Float(col) * 2.25

                box(b, "", [xw, y, 4.30], [1.12, 1.28, 0.10],
                    UIColor(red: 0.055, green: 0.10, blue: 0.13, alpha: 1), rough: 0.18, metal: true)

                box(b, "", [xw, y, 4.37], [1.16, 0.055, 0.07], UIColor(white: 0.64, alpha: 1), metal: true)

                box(b, "", [xw, y - 0.68, 4.38], [1.20, 0.06, 0.30], UIColor(white: 0.24, alpha: 1), metal: true)
            }
        }

        for floor in 0..<floors {
            let y = 1.45 + Float(floor) * (height / Float(floors))

            box(b, "", [3.74, y, -1.9], [0.10, 1.05, 1.0],
                UIColor(red: 0.06, green: 0.11, blue: 0.14, alpha: 1), rough: 0.2, metal: true)
        }
    }

    private func buildRV(in root: Entity, position: SIMD3<Float>) {
        let rv = Entity()
        rv.name = "GreenWhiteRV"
        rv.position = position
        root.addChild(rv)

        let cream = UIColor(red: 0.82, green: 0.82, blue: 0.75, alpha: 1)
        let green = UIColor(red: 0.075, green: 0.31, blue: 0.16, alpha: 1)
        let glass = UIColor(red: 0.035, green: 0.065, blue: 0.09, alpha: 1)

        box(rv, "RVBody", [0, 1.65, 0], [3.35, 2.85, 6.6], cream)
        box(rv, "", [0, 3.10, 0], [3.22, 0.16, 6.42], UIColor(white: 0.17, alpha: 1))
        box(rv, "", [0, 0.78, 0], [3.40, 0.72, 6.62], green)
        box(rv, "", [0, 1.12, 0], [3.42, 0.12, 6.64], UIColor(red: 0.91, green: 0.90, blue: 0.81, alpha: 1))

        for z: Float in [-2.15, -0.75, 0.75] {
            box(rv, "", [1.70, 2.08, z], [0.07, 1.05, 1.02], UIColor(white: 0.12, alpha: 1), metal: true)
            box(rv, "", [1.75, 2.08, z], [0.035, 0.88, 0.85], glass, rough: 0.12, metal: true)
        }

        box(rv, "", [1.73, 1.60, 2.45], [0.09, 2.42, 1.30], UIColor(white: 0.12, alpha: 1), metal: true)

        box(rv, "", [1.79, 1.60, 2.45], [0.035, 2.26, 1.14],
            UIColor(red: 0.48, green: 0.045, blue: 0.36, alpha: 1), rough: 0.22, metal: true)

        box(rv, "", [1.22, 0.52, 2.48], [0.88, 0.08, 1.12], UIColor(red: 0.20, green: 0.13, blue: 0.18, alpha: 1))

        box(rv, "", [0.65, 1.55, 2.35], [0.06, 2.20, 0.10], UIColor(white: 0.36, alpha: 1), metal: true)

        let pink = PointLight()
        pink.light.color = UIColor(red: 1.0, green: 0.08, blue: 0.62, alpha: 1)
        pink.light.intensity = 1800
        pink.light.attenuationRadius = 5
        pink.position = [0.45, 2.25, 2.1]
        rv.addChild(pink)

        for z: Float in [-2.05, 2.05] {
            cylinder(rv, [1.68, 0.58, z], radius: 0.58, height: 0.34,
                     color: UIColor(white: 0.055, alpha: 1),
                     rotation: simd_quatf(angle: .pi / 2, axis: [0, 0, 1]))

            cylinder(rv, [1.88, 0.58, z], radius: 0.27, height: 0.36,
                     color: UIColor(white: 0.42, alpha: 1),
                     rotation: simd_quatf(angle: .pi / 2, axis: [0, 0, 1]))
        }

        box(rv, "", [0, 2.20, -3.33], [2.55, 1.12, 0.06], glass, rough: 0.16, metal: true)

        for x: Float in [-1.25, 1.25] {
            box(rv, "", [x, 1.0, -3.38], [0.22, 0.42, 0.07], UIColor(red: 0.72, green: 0.08, blue: 0.055, alpha: 1))
        }

        box(rv, "", [1.85, 2.0, -2.8], [0.38, 0.12, 0.32], UIColor(white: 0.16, alpha: 1), metal: true)

        for step in 0..<3 {
            box(rv, "", [1.45, 0.22 + Float(step) * 0.25, 2.62 + Float(step) * 0.42],
                [1.35, 0.12, 0.62],
                UIColor(white: 0.22 + CGFloat(step) * 0.06, alpha: 1), metal: true)
        }

        box(rv, "", [0, 3.23, -1.4], [0.72, 0.12, 0.65], UIColor(white: 0.24, alpha: 1), metal: true)
    }

    private func add3DText(_ text: String, parent: Entity, position: SIMD3<Float>, size: Float, color: UIColor) {
        let mesh = MeshResource.generateText(text, extrusionDepth: 0.012,
                                             font: .systemFont(ofSize: CGFloat(size), weight: .bold),
                                             containerFrame: .zero, alignment: .center, lineBreakMode: .byClipping)

        let e = ModelEntity(mesh: mesh, materials: [mat(color, roughness: 0.7)])
        e.position = position
        parent.addChild(e)
    }

    private func buildStreetDetails(in root: Entity) {
        for z: Float in [-27, -8, 11, 29] {
            for x: Float in [-8.4, 8.4] {
                cylinder(root, [x, 2.5, z], radius: 0.075, height: 5.0,
                         color: UIColor(white: 0.13, alpha: 1))

                box(root, "", [x, 5.05, z], [0.70, 0.18, 0.70],
                    UIColor(red: 0.92, green: 0.78, blue: 0.52, alpha: 1), rough: 0.4)
            }
        }

        for z: Float in [-19, 1, 21] {
            cylinder(root, [-7.4, 1.0, z], radius: 0.16, height: 2.0,
                     color: UIColor(red: 0.25, green: 0.16, blue: 0.10, alpha: 1))

            let crown = ModelEntity(mesh: .generateCone(height: 3.1, radius: 1.15),
                                    materials: [mat(UIColor(red: 0.10, green: 0.30, blue: 0.17, alpha: 1))])

            crown.position = [-7.4, 3.15, z]
            root.addChild(crown)
        }

        for z: Float in [-12, 16] {
            box(root, "", [7.9, 0.65, z], [0.78, 1.25, 0.78],
                UIColor(red: 0.12, green: 0.34, blue: 0.22, alpha: 1))
        }
    }

    private func buildStarterProperty(in root: Entity) {
        let p = Entity()
        p.name = "StarterProperty"
        p.position = [0, 0, -34]
        root.addChild(p)

        box(p, "", [0, 1.7, 0], [8.5, 3.4, 7], UIColor(red: 0.31, green: 0.36, blue: 0.32, alpha: 1))
        box(p, "", [0, 3.55, 0], [8.9, 0.30, 7.4], UIColor(white: 0.12, alpha: 1))

        box(p, "", [0, 1.45, 3.56], [1.5, 2.9, 0.12],
            UIColor(red: 0.08, green: 0.15, blue: 0.17, alpha: 1), rough: 0.2, metal: true)

        box(p, "", [-2.4, 2.0, 3.56], [1.4, 1.4, 0.12],
            UIColor(red: 0.06, green: 0.12, blue: 0.14, alpha: 1), rough: 0.2, metal: true)
    }
}

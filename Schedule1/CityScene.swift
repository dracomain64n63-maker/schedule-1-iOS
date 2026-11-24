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
            sun.light.color = UIColor(red: 1.0, green: 0.86, blue: 0.70, alpha: 1)
            sun.orientation = simd_quatf(angle: -.pi / 3.4, axis: [1, 0, 0])
            world.addChild(sun)

            let ambient = PointLight()
            ambient.light.intensity = 2200
            ambient.light.attenuationRadius = 42
            ambient.position = [0, 12, 2]
            world.addChild(ambient)

            buildSky(in: world)
            buildRoad(in: world)
            buildOverpass(in: world)
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

    // MARK: - Helpers

    private func mat(_ color: UIColor, roughness: Float = 0.82, metal: Bool = false) -> SimpleMaterial {
        SimpleMaterial(color: color, roughness: .float(roughness), isMetallic: metal)
    }

    private func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        UIColor(red: r, green: g, blue: b, alpha: 1)
    }

    @discardableResult
    private func box(_ parent: Entity, _ name: String = "", _ p: SIMD3<Float>,
                     _ s: SIMD3<Float>, _ c: UIColor, rough: Float = 0.82,
                     metal: Bool = false, rot: simd_quatf = simd_quatf()) -> ModelEntity {
        let e = ModelEntity(mesh: .generateBox(size: s), materials: [mat(c, roughness: rough, metal: metal)])
        e.name = name
        e.position = p
        e.orientation = rot
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

    private func sphere(_ parent: Entity, _ p: SIMD3<Float>, radius: Float, color: UIColor,
                        rough: Float = 0.4, metal: Bool = false) {
        let e = ModelEntity(mesh: .generateSphere(radius: radius),
                            materials: [mat(color, roughness: rough, metal: metal)])
        e.position = p
        parent.addChild(e)
    }

    private func cone(_ parent: Entity, _ p: SIMD3<Float>, radius: Float, height: Float, color: UIColor) {
        let e = ModelEntity(mesh: .generateCone(height: height, radius: radius),
                            materials: [mat(color, roughness: 0.95)])
        e.position = p
        parent.addChild(e)
    }

    private func add3DText(_ text: String, parent: Entity, position: SIMD3<Float>, size: Float, color: UIColor) {
        let mesh = MeshResource.generateText(text, extrusionDepth: 0.012,
                                             font: .systemFont(ofSize: CGFloat(size), weight: .bold),
                                             containerFrame: .zero, alignment: .center, lineBreakMode: .byClipping)
        let e = ModelEntity(mesh: mesh, materials: [mat(color, roughness: 0.7)])
        e.position = position
        parent.addChild(e)
    }

    private func faceStreet(_ e: Entity, towardPositiveX: Bool) {
        e.orientation = simd_quatf(angle: towardPositiveX ? .pi / 2 : -.pi / 2, axis: [0, 1, 0])
    }

    private let glassColor = UIColor(red: 0.055, green: 0.105, blue: 0.13, alpha: 1)

    // MARK: - Sky

    private func buildSky(in root: Entity) {
        let dome = ModelEntity(mesh: .generateSphere(radius: 180),
                               materials: [UnlitMaterial(color: UIColor(red: 0.93, green: 0.66, blue: 0.52, alpha: 1))])
        dome.name = "SkyDome"
        dome.scale = [-1, 1, 1]
        dome.position = [0, 0, -8]
        root.addChild(dome)
    }

    // MARK: - Road

    private func buildRoad(in root: Entity) {
        box(root, "Road", [0, -0.14, -8], [34, 0.24, 82], rgb(0.105, 0.12, 0.13), rough: 1)
        box(root, "LeftWalk", [-9.4, 0.0, -8], [3.0, 0.28, 82], rgb(0.42, 0.42, 0.39))
        box(root, "RightWalk", [9.4, 0.0, -8], [3.0, 0.28, 82], rgb(0.42, 0.42, 0.39))
        // Curb strips
        for side: Float in [-1, 1] {
            box(root, "", [side * 7.95, 0.02, -8], [0.18, 0.30, 82], rgb(0.55, 0.50, 0.38))
        }
        // Grass/ground beyond sidewalks
        box(root, "GroundL", [-30, -0.2, -8], [40, 0.2, 100], rgb(0.18, 0.22, 0.15), rough: 1)
        box(root, "GroundR", [30, -0.2, -8], [40, 0.2, 100], rgb(0.18, 0.22, 0.15), rough: 1)

        for z in stride(from: 30.0, through: -48.0, by: -6.0) {
            box(root, "", [0, 0.012, Float(z)], [0.13, 0.025, 2.8], rgb(0.86, 0.82, 0.68))
        }
        for side: Float in [-1, 1] {
            box(root, "", [side * 7.7, 0.03, -8], [0.12, 0.05, 82], UIColor(white: 0.84, alpha: 1))
        }
        for i in 0..<7 {
            box(root, "", [-3.6 + Float(i) * 1.2, 0.015, -1.5], [0.72, 0.025, 3.4], UIColor(white: 0.85, alpha: 1))
        }
    }

    // MARK: - Elevated highway

    private func buildOverpass(in root: Entity) {
        let concrete = rgb(0.30, 0.31, 0.30)
        let steel = rgb(0.22, 0.30, 0.25)
        box(root, "OverpassDeck", [0, 9.0, -8], [24, 1.1, 90], concrete, rough: 0.95)
        box(root, "", [0, 8.2, -8], [22, 0.5, 90], rgb(0.20, 0.22, 0.21), rough: 0.95)
        for side: Float in [-1, 1] {
            box(root, "", [side * 11.8, 9.9, -8], [0.18, 0.9, 90], steel)
            box(root, "", [side * 11.8, 10.4, -8], [0.22, 0.10, 90], UIColor(white: 0.5, alpha: 1))
        }
        for z in stride(from: 28.0, through: -46.0, by: -12.0) {
            for side: Float in [-1, 1] {
                box(root, "", [side * 9.9, 4.2, Float(z)], [0.55, 8.4, 0.55], steel, metal: true)
                box(root, "", [side * 9.9, 8.0, Float(z)], [1.1, 0.35, 1.1], steel, metal: true)
            }
            box(root, "", [0, 8.0, Float(z)], [20, 0.35, 0.45], steel, metal: true)
            // hanging lamp
            cylinder(root, [0, 7.6, Float(z) - 6], radius: 0.03, height: 0.6, color: UIColor(white: 0.15, alpha: 1))
            cone(root, [0, 7.15, Float(z) - 6], radius: 0.45, height: 0.35, color: UIColor(white: 0.25, alpha: 1))
        }
    }

    // MARK: - Buildings

    private func buildCity(in root: Entity) {
        laundromat(root, x: -12.0, z: -5.0)
        diner(root, x: 12.5, z: -6.0)
        gasStation(root, x: 12.0, z: 14.0)
        dealership(root, x: -13.5, z: 14.0)

        apartment(root, x: -13, z: -22, height: 12, floors: 4,
                  color: rgb(0.45, 0.28, 0.22), faceRight: true)
        apartment(root, x: 13, z: -22, height: 14, floors: 5,
                  color: rgb(0.38, 0.27, 0.22), faceRight: false)
        apartment(root, x: -14, z: -40, height: 16, floors: 6,
                  color: rgb(0.34, 0.35, 0.36), faceRight: true)
        apartment(root, x: 14, z: -41, height: 15, floors: 5,
                  color: rgb(0.50, 0.40, 0.30), faceRight: false)
    }

    private func laundromat(_ root: Entity, x: Float, z: Float) {
        let g = Entity()
        g.position = [x, 0, z]
        faceStreet(g, towardPositiveX: true)
        root.addChild(g)
        let width: Float = 9.0, height: Float = 4.6, depth: Float = 7.0   // local: width along local x
        box(g, "ShopBody", [0, height / 2, 0], [width, height, depth], rgb(0.20, 0.22, 0.24))
        box(g, "", [0, height + 0.12, 0], [width + 0.3, 0.26, depth + 0.3], UIColor(white: 0.10, alpha: 1))
        // blue sign band
        box(g, "", [0, height - 0.55, depth / 2 + 0.10], [width, 1.1, 0.2], rgb(0.10, 0.28, 0.62), rough: 0.5)
        add3DText("LAUNDROMAT", parent: g, position: [-width * 0.42, height - 0.78, depth / 2 + 0.22],
                  size: 0.62, color: .white)
        // big glass front
        box(g, "", [0, 1.9, depth / 2 + 0.06], [width - 0.6, 2.7, 0.09], rgb(0.62, 0.74, 0.80), rough: 0.1, metal: true)
        for px in stride(from: -width / 2 + 0.3, through: width / 2 - 0.3, by: 1.5) {
            box(g, "", [px, 1.9, depth / 2 + 0.12], [0.07, 2.7, 0.07], UIColor(white: 0.85, alpha: 1))
        }
        // washing machines visible through glass
        for i in 0..<3 {
            let mx = -2.6 + Float(i) * 1.3
            for row in 0..<2 {
                let my = 0.8 + Float(row) * 1.1
                box(g, "", [mx, my, depth / 2 - 0.5], [1.0, 1.0, 0.9], UIColor(white: 0.90, alpha: 1))
                cylinder(g, [mx, my, depth / 2 - 0.02], radius: 0.34, height: 0.06,
                         color: rgb(0.10, 0.13, 0.16),
                         rotation: simd_quatf(angle: .pi / 2, axis: [1, 0, 0]))
            }
        }
        // double door with black frame
        box(g, "", [3.2, 1.35, depth / 2 + 0.16], [1.9, 2.5, 0.08], UIColor(white: 0.04, alpha: 1))
        box(g, "", [2.75, 1.35, depth / 2 + 0.22], [0.8, 2.2, 0.05], rgb(0.62, 0.74, 0.80), rough: 0.1, metal: true)
        box(g, "", [3.65, 1.35, depth / 2 + 0.22], [0.8, 2.2, 0.05], rgb(0.62, 0.74, 0.80), rough: 0.1, metal: true)
        // steps
        for s in 0..<2 {
            box(g, "", [3.2, 0.08 + Float(s) * 0.12, depth / 2 + 0.55 - Float(s) * 0.25],
                [2.2, 0.16, 0.8 - Float(s) * 0.3], UIColor(white: 0.35, alpha: 1))
        }
    }

    private func diner(_ root: Entity, x: Float, z: Float) {
        let g = Entity()
        g.position = [x, 0, z]
        faceStreet(g, towardPositiveX: false)
        root.addChild(g)
        let width: Float = 11.0, height: Float = 3.8, depth: Float = 8.0
        box(g, "ShopBody", [0, height / 2, 0], [width, height, depth], rgb(0.78, 0.76, 0.70))
        // red/orange diner stripes
        box(g, "", [0, 1.0, depth / 2 + 0.05], [width + 0.1, 1.2, 0.12], rgb(0.78, 0.16, 0.12))
        box(g, "", [0, 3.0, depth / 2 + 0.05], [width + 0.1, 1.2, 0.12], rgb(0.80, 0.22, 0.14))
        box(g, "", [0, 3.7, depth / 2 + 0.08], [width + 0.1, 0.18, 0.16], rgb(0.95, 0.50, 0.20))
        box(g, "", [0, 0.45, depth / 2 + 0.07], [width + 0.1, 0.2, 0.14], rgb(0.95, 0.50, 0.20))
        // dark window strip
        for i in 0..<5 {
            box(g, "", [-4.2 + Float(i) * 2.1, 2.0, depth / 2 + 0.10], [1.8, 1.1, 0.06],
                rgb(0.07, 0.09, 0.11), rough: 0.15, metal: true)
        }
        box(g, "", [0, height + 0.15, 0], [width + 0.3, 0.3, depth + 0.3], UIColor(white: 0.14, alpha: 1))
    }

    private func gasStation(_ root: Entity, x: Float, z: Float) {
        let g = Entity()
        g.position = [x, 0, z]
        root.addChild(g)
        // Canopy
        box(g, "", [-2.0, 4.2, 0], [7.0, 0.7, 6.0], rgb(0.95, 0.55, 0.12))
        box(g, "", [-2.0, 4.4, 0], [7.1, 0.22, 6.1], rgb(0.80, 0.14, 0.10))
        box(g, "", [-2.0, 4.0, 0], [6.8, 0.12, 5.8], UIColor(white: 0.9, alpha: 1), rough: 0.3)
        for px: Float in [-3.2, -0.8] {
            box(g, "", [px, 2.0, 0], [0.35, 4.0, 0.35], UIColor(white: 0.75, alpha: 1), metal: true)
        }
        // Pumps
        for pz: Float in [-1.2, 1.2] {
            box(g, "", [-2.0, 0.55, pz], [0.7, 1.1, 0.45], UIColor(white: 0.9, alpha: 1))
            box(g, "", [-2.0, 1.3, pz], [0.72, 0.5, 0.47], rgb(0.80, 0.14, 0.10))
        }
        // Store
        let store = Entity()
        store.position = [5.0, 0, 0]
        store.orientation = simd_quatf(angle: -.pi / 2, axis: [0, 1, 0])
        g.addChild(store)
        box(store, "", [0, 1.8, 0], [10.0, 3.6, 5.0], rgb(0.86, 0.80, 0.70))
        box(store, "", [0, 3.0, 2.55], [10.2, 0.9, 0.2], rgb(0.95, 0.50, 0.10))
        box(store, "", [0, 3.7, 2.55], [10.2, 0.35, 0.22], rgb(0.80, 0.14, 0.10))
        box(store, "", [0, 3.9, 0], [10.3, 0.3, 5.3], UIColor(white: 0.20, alpha: 1))
        box(store, "", [-1.0, 1.5, 2.54], [4.5, 1.8, 0.08], rgb(0.07, 0.09, 0.11), rough: 0.15, metal: true)
        box(store, "", [3.4, 1.2, 2.54], [1.3, 2.3, 0.08], UIColor(white: 0.30, alpha: 1), metal: true)
        // Price pylon sign
        box(g, "", [-6.5, 3.0, 3.0], [0.25, 6.0, 0.25], UIColor(white: 0.30, alpha: 1), metal: true)
        box(g, "", [-6.5, 5.6, 3.0], [1.1, 1.4, 0.2], UIColor(white: 0.92, alpha: 1))
        box(g, "", [-6.5, 5.9, 3.12], [0.9, 0.35, 0.05], rgb(0.80, 0.14, 0.10))
        // Parked blue SUV
        suv(g, position: [1.5, 0, 6.0], color: rgb(0.14, 0.15, 0.42))
    }

    private func suv(_ root: Entity, position: SIMD3<Float>, color: UIColor) {
        let s = Entity()
        s.position = position
        root.addChild(s)
        box(s, "", [0, 0.85, 0], [1.9, 0.9, 4.4], color, rough: 0.35)
        box(s, "", [0, 1.55, -0.2], [1.8, 0.7, 2.7], color, rough: 0.35)
        box(s, "", [0, 1.57, -0.2], [1.84, 0.5, 2.5], rgb(0.07, 0.10, 0.14), rough: 0.1, metal: true)
        for sx: Float in [-0.95, 0.95] {
            for sz: Float in [-1.45, 1.45] {
                cylinder(s, [sx, 0.38, sz], radius: 0.38, height: 0.28, color: UIColor(white: 0.05, alpha: 1),
                         rotation: simd_quatf(angle: .pi / 2, axis: [0, 0, 1]))
            }
        }
    }

    private func dealership(_ root: Entity, x: Float, z: Float) {
        let g = Entity()
        g.position = [x, 0, z]
        faceStreet(g, towardPositiveX: true)
        root.addChild(g)
        let width: Float = 14.0, height: Float = 4.0, depth: Float = 8.0
        box(g, "", [0, height / 2, 0], [width, height, depth], rgb(0.30, 0.32, 0.34))
        box(g, "", [0, height + 0.2, 0], [width + 0.6, 0.4, depth + 0.6], UIColor(white: 0.20, alpha: 1))
        box(g, "", [0, 1.9, depth / 2 + 0.06], [width - 0.8, 3.0, 0.09], rgb(0.10, 0.14, 0.17), rough: 0.1, metal: true)
        for px in stride(from: -width / 2 + 1.0, through: width / 2 - 1.0, by: 2.4) {
            box(g, "", [px, 1.9, depth / 2 + 0.12], [0.08, 3.0, 0.08], UIColor(white: 0.5, alpha: 1), metal: true)
        }
        add3DText("Hyland Auto", parent: g, position: [0.5, height - 0.55, depth / 2 + 0.16],
                  size: 0.36, color: .white)
        // vehicle visible inside
        let inside = Entity()
        inside.position = [-2.0, 0, 0]
        g.addChild(inside)
        box(inside, "", [0, 0.8, 0], [1.9, 0.8, 4.0], UIColor(white: 0.2, alpha: 1))
        box(inside, "", [0, 1.4, 0], [1.8, 0.6, 2.4], UIColor(white: 0.16, alpha: 1))
    }

    private func apartment(_ root: Entity, x: Float, z: Float, height: Float, floors: Int,
                           color: UIColor, faceRight: Bool) {
        let b = Entity()
        b.position = [x, 0, z]
        faceStreet(b, towardPositiveX: faceRight)
        root.addChild(b)
        box(b, "", [0, height / 2, 0], [8.5, height, 7.4], color)
        box(b, "", [0, height + 0.16, 0], [8.8, 0.32, 7.7], UIColor(white: 0.13, alpha: 1))
        for floor in 0..<floors {
            let y = 1.45 + Float(floor) * (height / Float(floors))
            for col in 0..<3 {
                let xw = -2.4 + Float(col) * 2.4
                box(b, "", [xw, y, 3.74], [1.12, 1.28, 0.10], glassColor, rough: 0.18, metal: true)
                box(b, "", [xw, y, 3.81], [1.16, 0.055, 0.07], UIColor(white: 0.80, alpha: 1), metal: true)
                box(b, "", [xw, y - 0.68, 3.82], [1.20, 0.08, 0.30], UIColor(white: 0.70, alpha: 1))
            }
        }
    }

    // MARK: - RV (cream wood-panel body, green stripes, sloped windshield)

    private func buildRV(in root: Entity, position: SIMD3<Float>) {
        let rv = Entity()
        rv.name = "GreenWhiteRV"
        rv.position = position
        root.addChild(rv)

        let cream = rgb(0.86, 0.80, 0.66)
        let tan = rgb(0.72, 0.64, 0.48)
        let green = rgb(0.16, 0.36, 0.17)
        let darkGreen = rgb(0.09, 0.24, 0.11)
        let glass = rgb(0.09, 0.12, 0.15)
        let trim = UIColor(white: 0.10, alpha: 1)

        // Main body (front is -z)
        box(rv, "RVBody", [0, 1.75, 0.4], [3.3, 2.7, 6.0], cream)
        // Wood-style horizontal panel lines on both sides
        for sx: Float in [-1.66, 1.66] {
            for i in 0..<5 {
                box(rv, "", [sx, 1.7 + Float(i) * 0.3, 0.4], [0.02, 0.03, 5.9], tan)
            }
        }
        // Green stripe band, lower body
        box(rv, "", [0, 0.95, 0.4], [3.36, 0.55, 6.02], green)
        box(rv, "", [0, 0.55, 0.4], [3.34, 0.45, 6.0], darkGreen)
        box(rv, "", [0, 1.28, 0.4], [3.38, 0.07, 6.04], rgb(0.92, 0.90, 0.78))
        // Roof
        box(rv, "", [0, 3.14, 0.4], [3.3, 0.14, 6.0], green)
        // Roof AC and vent
        box(rv, "", [0, 3.35, 1.6], [1.1, 0.30, 1.3], UIColor(white: 0.85, alpha: 1))
        box(rv, "", [0, 3.28, -0.4], [0.5, 0.16, 0.5], UIColor(white: 0.72, alpha: 1))

        // Sloped nose
        box(rv, "", [0, 1.15, -3.0], [3.3, 1.5, 0.9], cream,
            rot: simd_quatf(angle: -0.35, axis: [1, 0, 0]))
        box(rv, "", [0, 0.95, -3.35], [3.3, 0.55, 0.5], green)
        // Windshield (tilted)
        box(rv, "", [0, 2.45, -2.92], [3.0, 1.35, 0.10], glass, rough: 0.1, metal: true,
            rot: simd_quatf(angle: 0.42, axis: [1, 0, 0]))
        box(rv, "", [0, 2.45, -2.88], [3.2, 1.50, 0.06], trim,
            rot: simd_quatf(angle: 0.42, axis: [1, 0, 0]))
        // Front roof cap
        box(rv, "", [0, 3.14, -2.75], [3.3, 0.14, 0.8], green)
        // Grille + headlights + bumper
        box(rv, "", [0, 0.85, -3.58], [1.5, 0.35, 0.08], UIColor(white: 0.18, alpha: 1), metal: true)
        box(rv, "", [0, 0.62, -3.62], [1.5, 0.05, 0.05], UIColor(white: 0.55, alpha: 1), metal: true)
        for hx: Float in [-1.2, 1.2] {
            cylinder(rv, [hx, 0.9, -3.58], radius: 0.19, height: 0.10,
                     color: UIColor(white: 0.9, alpha: 1),
                     rotation: simd_quatf(angle: .pi / 2, axis: [1, 0, 0]))
        }
        box(rv, "", [0, 0.38, -3.65], [3.4, 0.28, 0.35], UIColor(white: 0.07, alpha: 1))

        // Side windows (+x side) and a small window on the -x side
        for z: Float in [-1.4, -0.3] {
            box(rv, "", [1.67, 2.2, z], [0.06, 0.95, 0.9], trim, metal: true)
            box(rv, "", [1.70, 2.2, z], [0.03, 0.78, 0.75], glass, rough: 0.12, metal: true)
        }
        box(rv, "", [-1.67, 2.2, -0.8], [0.06, 0.95, 1.0], trim, metal: true)
        box(rv, "", [-1.70, 2.2, -0.8], [0.03, 0.78, 0.85], glass, rough: 0.12, metal: true)
        // Rear small window
        box(rv, "", [0, 2.2, 3.43], [1.0, 0.7, 0.05], glass, rough: 0.12, metal: true)

        // Door (+x side, rear half) with small window
        box(rv, "", [1.68, 1.55, 1.9], [0.07, 2.2, 0.95], trim, metal: true)
        box(rv, "", [1.72, 1.55, 1.9], [0.04, 2.05, 0.8], cream)
        box(rv, "", [1.75, 2.05, 1.9], [0.03, 0.7, 0.55], glass, rough: 0.12, metal: true)
        box(rv, "", [1.75, 1.35, 1.55], [0.04, 0.10, 0.18], UIColor(white: 0.55, alpha: 1), metal: true)
        for step in 0..<2 {
            box(rv, "", [1.95 + Float(step) * 0.0, 0.25 + Float(step) * 0.25, 1.9],
                [0.5 - Float(step) * 0.15, 0.12, 1.0], UIColor(white: 0.25, alpha: 1), metal: true)
        }

        // Tail lights
        for x: Float in [-1.25, 1.25] {
            box(rv, "", [x, 1.0, 3.43], [0.22, 0.42, 0.07], rgb(0.72, 0.08, 0.055))
        }
        box(rv, "", [0, 0.40, 3.45], [3.3, 0.22, 0.2], UIColor(white: 0.10, alpha: 1))

        // Wheels
        for z: Float in [-1.8, 2.3] {
            for x: Float in [-1.62, 1.62] {
                cylinder(rv, [x, 0.55, z], radius: 0.55, height: 0.36,
                         color: UIColor(white: 0.05, alpha: 1),
                         rotation: simd_quatf(angle: .pi / 2, axis: [0, 0, 1]))
                cylinder(rv, [x + (x > 0 ? 0.08 : -0.08), 0.55, z], radius: 0.26, height: 0.30,
                         color: UIColor(white: 0.45, alpha: 1),
                         rotation: simd_quatf(angle: .pi / 2, axis: [0, 0, 1]))
            }
        }
    }

    // MARK: - Street details

    private func trafficSignal(_ root: Entity, x: Float, z: Float, armDirection: Float) {
        let poleColor = rgb(0.30, 0.18, 0.10)
        box(root, "", [x, 3.0, z], [0.22, 6.0, 0.22], poleColor)
        box(root, "", [x + armDirection * 3.2, 5.6, z], [6.4, 0.16, 0.16], poleColor)
        let sx = x + armDirection * 5.2
        box(root, "", [sx, 5.0, z], [0.35, 1.15, 0.30], UIColor(white: 0.07, alpha: 1))
        sphere(root, [sx, 5.35, z + 0.17], radius: 0.10, color: rgb(0.7, 0.1, 0.1))
        sphere(root, [sx, 5.0, z + 0.17], radius: 0.10, color: rgb(0.7, 0.55, 0.1))
        sphere(root, [sx, 4.65, z + 0.17], radius: 0.10, color: rgb(0.1, 0.8, 0.3))
    }

    private func pine(_ root: Entity, x: Float, z: Float, scale: Float = 1) {
        let trunk = rgb(0.25, 0.16, 0.10)
        let leaf = rgb(0.10, 0.30, 0.17)
        cylinder(root, [x, 0.6 * scale, z], radius: 0.18 * scale, height: 1.2 * scale, color: trunk)
        cone(root, [x, 2.0 * scale, z], radius: 1.35 * scale, height: 2.2 * scale, color: leaf)
        cone(root, [x, 3.3 * scale, z], radius: 1.05 * scale, height: 2.0 * scale, color: leaf)
        cone(root, [x, 4.5 * scale, z], radius: 0.70 * scale, height: 1.8 * scale, color: leaf)
    }

    private func buildStreetDetails(in root: Entity) {
        // Street lamps
        for z: Float in [-27, 11, 29] {
            for x: Float in [-8.4, 8.4] {
                cylinder(root, [x, 2.5, z], radius: 0.075, height: 5.0, color: UIColor(white: 0.13, alpha: 1))
                box(root, "", [x, 5.05, z], [0.70, 0.18, 0.70], rgb(0.92, 0.78, 0.52), rough: 0.4)
            }
        }

        // Traffic signals on arm poles
        trafficSignal(root, x: 8.6, z: -30, armDirection: -1)
        trafficSignal(root, x: -8.6, z: 4, armDirection: 1)

        // Power poles with crossarms and wires
        for z: Float in [-20, 6, 24] {
            box(root, "", [-8.9, 4.5, z], [0.2, 9.0, 0.2], rgb(0.28, 0.20, 0.13))
            box(root, "", [-8.9, 8.2, z], [1.8, 0.14, 0.14], rgb(0.28, 0.20, 0.13))
        }
        for dy: Float in [-0.7, 0, 0.7] {
            box(root, "", [-8.9 + dy, 8.3, 2], [0.02, 0.02, 44], UIColor(white: 0.05, alpha: 1))
        }

        // Pine trees
        for z: Float in [-19, 1, 21, -33, 31] {
            pine(root, x: -7.4, z: z)
        }
        pine(root, x: 7.6, z: -15, scale: 1.1)
        pine(root, x: 7.8, z: -26, scale: 0.9)
        pine(root, x: -22, z: 0, scale: 1.4)
        pine(root, x: 22, z: -20, scale: 1.3)
        pine(root, x: -22, z: -30, scale: 1.2)

        // Fire hydrants
        for z: Float in [-12, 16] {
            cylinder(root, [7.7, 0.45, z], radius: 0.16, height: 0.9, color: rgb(0.78, 0.10, 0.08))
            sphere(root, [7.7, 0.95, z], radius: 0.17, color: rgb(0.78, 0.10, 0.08))
            cylinder(root, [7.7, 0.55, z], radius: 0.07, height: 0.55, color: rgb(0.78, 0.10, 0.08),
                     rotation: simd_quatf(angle: .pi / 2, axis: [0, 0, 1]))
        }

        // Green utility boxes and wooden crate
        box(root, "", [8.5, 0.65, -9.5], [0.9, 1.3, 0.8], rgb(0.18, 0.40, 0.22))
        box(root, "", [8.5, 1.35, -9.5], [0.95, 0.12, 0.85], rgb(0.12, 0.30, 0.16))
        box(root, "", [9.7, 0.50, -9.0], [1.0, 1.0, 1.0], rgb(0.55, 0.38, 0.20))
        box(root, "", [9.7, 0.50, -9.0], [1.02, 0.08, 1.02], rgb(0.38, 0.26, 0.14))
        box(root, "", [9.8, 0.5, -20], [1.8, 1.0, 1.0], rgb(0.15, 0.30, 0.18))
    }

    // MARK: - Starter property

    private func buildStarterProperty(in root: Entity) {
        let p = Entity()
        p.name = "StarterProperty"
        p.position = [0, 0, -34]
        root.addChild(p)

        box(p, "", [0, 1.7, 0], [8.5, 3.4, 7], rgb(0.31, 0.36, 0.32))
        box(p, "", [0, 3.55, 0], [8.9, 0.30, 7.4], UIColor(white: 0.12, alpha: 1))
        box(p, "", [0, 1.45, 3.56], [1.5, 2.9, 0.12], rgb(0.08, 0.15, 0.17), rough: 0.2, metal: true)
        box(p, "", [-2.4, 2.0, 3.56], [1.4, 1.4, 0.12], rgb(0.06, 0.12, 0.14), rough: 0.2, metal: true)
    }
}

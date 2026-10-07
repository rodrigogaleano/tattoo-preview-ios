import Foundation
import RealityKit
import UIKit

final class AvatarSceneController {
    let root = Entity()

    private static let cameraDistance: Float = 2.6
    private static let skinColor = UIColor(red: 0.87, green: 0.72, blue: 0.62, alpha: 1)

    init() {
        addCamera()
        addLights()
    }

    func loadAvatar() async throws {
        let avatar = try await Entity(named: "avatar", in: .main)
        applySkinMaterial(to: avatar)
        let bounds = avatar.visualBounds(relativeTo: nil)
        avatar.position = -bounds.center
        root.addChild(avatar)
    }

    private func addCamera() {
        let camera = PerspectiveCamera()
        camera.position = [0, 0, Self.cameraDistance]
        root.addChild(camera)
    }

    private func addLights() {
        let key = DirectionalLight()
        key.light.intensity = 3_000
        key.look(at: .zero, from: [1, 2, 2], relativeTo: nil)
        root.addChild(key)

        let fill = DirectionalLight()
        fill.light.intensity = 1_000
        fill.look(at: .zero, from: [-2, 1, -1], relativeTo: nil)
        root.addChild(fill)
    }

    private func applySkinMaterial(to entity: Entity) {
        if var model = entity.components[ModelComponent.self] {
            var material = PhysicallyBasedMaterial()
            material.baseColor = .init(tint: Self.skinColor)
            material.roughness = 0.6
            model.materials = model.materials.map { _ in material }
            entity.components.set(model)
        }
        for child in entity.children {
            applySkinMaterial(to: child)
        }
    }
}

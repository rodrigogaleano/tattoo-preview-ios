import Foundation
import RealityKit
import UIKit

final class AvatarSceneController {
    let root = Entity()

    private static let cameraDistance: Float = 2.6
    private static let skinTextureSize = 2048

    private var body: Entity?
    private var bodyMesh: DeformableMesh?
    private var hitTester: MeshHitTester?
    private var configuration = AvatarConfiguration()
    private var skinTexture: TextureResource?

    init() {
        addCamera()
        addLights()
    }

    func loadAvatar() async throws {
        let avatar = try await Entity(named: "avatar", in: .main)
        let bounds = avatar.visualBounds(relativeTo: nil)
        avatar.position = -bounds.center
        root.addChild(avatar)

        body = Self.firstModelEntity(in: avatar)
        if let body {
            bodyMesh = Self.makeDeformableMesh(from: body, relativeTo: root)
        }
        applyWeight()
        applyMaterial()
    }

    func apply(_ newConfiguration: AvatarConfiguration) {
        let old = configuration
        configuration = newConfiguration
        if old.weight != newConfiguration.weight { applyWeight() }
        if old.skinTone != newConfiguration.skinTone { applyMaterial() }
    }

    func hitTest(origin: SIMD3<Float>, direction: SIMD3<Float>) -> MeshHit? {
        if hitTester == nil {
            hitTester = bodyMesh?.hitTester(weights: blendShapeWeights)
        }
        return hitTester?.hit(origin: origin, direction: direction)
    }

    func applyTattoo(_ tattoo: CGImage, placement: TattooPlacement?) throws {
        guard let placement else {
            skinTexture = nil
            applyMaterial()
            return
        }
        guard let image = TattooCompositor.compose(tattoo: tattoo, placement: placement, size: Self.skinTextureSize)
        else { return }

        let options = TextureResource.CreateOptions(semantic: .color)
        if let skinTexture {
            try skinTexture.replace(withImage: image, options: options)
        } else {
            skinTexture = try TextureResource(image: image, options: options)
        }
        applyMaterial()
    }

    private var blendShapeWeights: [String: Float] {
        ["weight_light": max(0, -configuration.weight), "weight_heavy": max(0, configuration.weight)]
    }

    private func applyWeight() {
        if let body {
            Self.apply(weights: blendShapeWeights, to: body)
        }
        hitTester = nil
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

    private func applyMaterial() {
        guard let body, var model = body.components[ModelComponent.self] else { return }
        let tint = configuration.skinTone.color

        var material = PhysicallyBasedMaterial()
        if let skinTexture {
            material.baseColor = .init(tint: tint, texture: .init(skinTexture))
        } else {
            material.baseColor = .init(tint: tint)
        }
        material.roughness = 0.6
        model.materials = model.materials.map { _ in material }
        body.components.set(model)
    }

    private static func apply(weights: [String: Float], to entity: Entity) {
        var component = entity.components[BlendShapeWeightsComponent.self]
        if component == nil, let mesh = entity.components[ModelComponent.self]?.mesh {
            component = BlendShapeWeightsComponent(weightsMapping: BlendShapeWeightsMapping(meshResource: mesh))
        }
        guard var component else { return }
        for index in component.weightSet.indices {
            var data = component.weightSet[index]
            for (position, name) in data.weightNames.enumerated() {
                data.weights[position] = weights[name] ?? 0
            }
            component.weightSet[index] = data
        }
        entity.components.set(component)
    }

    static func firstModelEntity(in entity: Entity) -> Entity? {
        if entity.components.has(ModelComponent.self) {
            return entity
        }
        for child in entity.children {
            if let model = firstModelEntity(in: child) {
                return model
            }
        }
        return nil
    }

    /// Cópia na CPU com a transform de cada instância já aplicada.
    static func makeDeformableMesh(from entity: Entity, relativeTo reference: Entity?) -> DeformableMesh? {
        guard let mesh = entity.components[ModelComponent.self]?.mesh else { return nil }
        var result = DeformableMesh(
            positions: [], uvs: [], indices: [], blendShapeOffsets: [:],
            transform: entity.transformMatrix(relativeTo: reference)
        )

        for instance in mesh.contents.instances {
            guard let model = mesh.contents.models[instance.model] else { continue }
            let linear = simd_float3x3(
                instance.transform.columns.0.xyz, instance.transform.columns.1.xyz, instance.transform.columns.2.xyz
            )
            for part in model.parts {
                guard let uvs = part.textureCoordinates?.elements,
                      let indices = part.triangleIndices?.elements else { continue }
                let positions = part.positions.elements
                guard uvs.count == positions.count else { continue }

                let base = UInt32(result.positions.count)
                result.positions += positions.map { (instance.transform * SIMD4<Float>($0, 1)).xyz }
                result.uvs += uvs
                result.indices += indices.map { $0 + base }

                for name in part.blendShapeNames {
                    let offsets = part.blendShapeOffsets(named: name)?.elements.map { linear * $0 }
                        ?? Array(repeating: .zero, count: positions.count)
                    var accumulated = result.blendShapeOffsets[name]
                        ?? Array(repeating: .zero, count: Int(base))
                    accumulated += offsets
                    result.blendShapeOffsets[name] = accumulated
                }
            }
        }
        return result.positions.isEmpty ? nil : result
    }
}

private extension SIMD4 where Scalar == Float {
    var xyz: SIMD3<Float> { SIMD3(x, y, z) }
}

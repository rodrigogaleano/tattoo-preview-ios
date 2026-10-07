import Foundation
import RealityKit
import Testing
@testable import TattooPreview

@MainActor
struct AvatarAssetTests {
    @Test func avatarHasMeshUVAndBlendShapes() async throws {
        let avatar = try await Entity(named: "avatar", in: .main)
        let model = try #require(firstModel(in: avatar))
        let mesh = model.mesh

        let hasUV = mesh.contents.models.contains { model in
            model.parts.contains { $0.textureCoordinates != nil }
        }
        #expect(hasUV)

        let blendShapes = BlendShapeWeightsComponent(weightsMapping: BlendShapeWeightsMapping(meshResource: mesh))
        let weightNames = blendShapes.weightSet.flatMap(\.weightNames)
        #expect(!weightNames.isEmpty)
    }

    @Test func frontalRayHitsTorsoWithValidUV() async throws {
        let avatar = try await Entity(named: "avatar", in: .main)
        let body = try #require(AvatarSceneController.firstModelEntity(in: avatar))
        let mesh = try #require(AvatarSceneController.makeDeformableMesh(from: body, relativeTo: nil))
        let bounds = avatar.visualBounds(relativeTo: nil)
        let origin = SIMD3<Float>(bounds.center.x, bounds.center.y + bounds.extents.y * 0.2, bounds.max.z + 1)

        let hit = try #require(mesh.hitTester(weights: [:]).hit(origin: origin, direction: [0, 0, -1]))

        #expect((0...1).contains(hit.uv.x))
        #expect((0...1).contains(hit.uv.y))
        #expect(hit.uvUnitsPerMeter > 0)
    }

    @Test func blendShapeOffsetsMatchWeightNames() async throws {
        let avatar = try await Entity(named: "avatar", in: .main)
        let body = try #require(AvatarSceneController.firstModelEntity(in: avatar))
        let mesh = try #require(AvatarSceneController.makeDeformableMesh(from: body, relativeTo: nil))

        #expect(Set(mesh.blendShapeOffsets.keys).isSuperset(of: ["weight_light", "weight_heavy"]))
        #expect(mesh.blendShapeOffsets.values.allSatisfy { $0.count == mesh.positions.count })
    }

    private func firstModel(in entity: Entity) -> ModelComponent? {
        if let model = entity.components[ModelComponent.self] {
            return model
        }
        for child in entity.children {
            if let model = firstModel(in: child) {
                return model
            }
        }
        return nil
    }
}

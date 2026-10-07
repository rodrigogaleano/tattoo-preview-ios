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

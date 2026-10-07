import Foundation
import simd

/// Cópia do mesh na CPU com os offsets das blend shapes, para o raycast enxergar
/// o mesmo corpo deformado que a GPU desenha.
nonisolated struct DeformableMesh {
    var positions: [SIMD3<Float>]
    var uvs: [SIMD2<Float>]
    var indices: [UInt32]
    /// Offsets por vértice, indexados pelo nome da blend shape.
    var blendShapeOffsets: [String: [SIMD3<Float>]]
    /// Transform do espaço do mesh para o espaço da cena.
    var transform: simd_float4x4

    func hitTester(weights: [String: Float]) -> MeshHitTester {
        var deformed = positions
        for (name, weight) in weights where weight != 0 {
            guard let offsets = blendShapeOffsets[name], offsets.count == deformed.count else { continue }
            for index in deformed.indices {
                deformed[index] += offsets[index] * weight
            }
        }
        let world = deformed.map { position in
            let transformed = transform * SIMD4<Float>(position, 1)
            return SIMD3<Float>(transformed.x, transformed.y, transformed.z)
        }
        return MeshHitTester(positions: world, uvs: uvs, indices: indices)
    }
}

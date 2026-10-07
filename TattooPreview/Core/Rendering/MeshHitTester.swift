import Foundation
import simd

nonisolated struct MeshHit: Equatable {
    var position: SIMD3<Float>
    var distance: Float
    var uv: SIMD2<Float>
    /// Quantas unidades de UV cabem em um metro de superfície no triângulo atingido.
    var uvUnitsPerMeter: Float
}

/// Raycast contra os triângulos de uma cópia do mesh na CPU, devolvendo o UV do ponto atingido.
nonisolated struct MeshHitTester {
    private let positions: [SIMD3<Float>]
    private let uvs: [SIMD2<Float>]
    private let indices: [UInt32]

    init(positions: [SIMD3<Float>], uvs: [SIMD2<Float>], indices: [UInt32]) {
        precondition(positions.count == uvs.count, "Cada vértice precisa de um UV")
        precondition(indices.count.isMultiple(of: 3), "Índices precisam formar triângulos")
        self.positions = positions
        self.uvs = uvs
        self.indices = indices
    }

    private struct Intersection {
        var distance: Float
        var triangle: Int
        /// Pesos dos vértices 1 e 2; o do vértice 0 é o complemento.
        var barycentric: SIMD2<Float>
    }

    func hit(origin: SIMD3<Float>, direction: SIMD3<Float>) -> MeshHit? {
        let direction = normalize(direction)
        var best: Intersection?

        for triangle in stride(from: 0, to: indices.count, by: 3) {
            guard let candidate = intersect(origin: origin, direction: direction, triangle: triangle),
                  candidate.distance < best?.distance ?? .infinity else { continue }
            best = candidate
        }

        guard let best else { return nil }
        return makeHit(origin: origin, direction: direction, intersection: best)
    }

    private func makeHit(origin: SIMD3<Float>, direction: SIMD3<Float>, intersection: Intersection) -> MeshHit {
        let corners = (0..<3).map { Int(indices[intersection.triangle + $0]) }
        let barycentric = intersection.barycentric
        let distance = intersection.distance
        let weights = SIMD3<Float>(1 - barycentric.x - barycentric.y, barycentric.x, barycentric.y)
        let uv = uvs[corners[0]] * weights.x + uvs[corners[1]] * weights.y + uvs[corners[2]] * weights.z

        let worldArea = length(cross(positions[corners[1]] - positions[corners[0]],
                                     positions[corners[2]] - positions[corners[0]]))
        let uvEdge1 = uvs[corners[1]] - uvs[corners[0]]
        let uvEdge2 = uvs[corners[2]] - uvs[corners[0]]
        let uvArea = abs(uvEdge1.x * uvEdge2.y - uvEdge1.y * uvEdge2.x)
        let density = worldArea > 0 ? sqrt(uvArea / worldArea) : 0

        return MeshHit(position: origin + direction * distance, distance: distance, uv: uv, uvUnitsPerMeter: density)
    }

    /// Möller–Trumbore. Considera as duas faces do triângulo.
    private func intersect(origin: SIMD3<Float>, direction: SIMD3<Float>, triangle: Int) -> Intersection? {
        let epsilon: Float = 1e-7
        let vertex0 = positions[Int(indices[triangle])]
        let edge1 = positions[Int(indices[triangle + 1])] - vertex0
        let edge2 = positions[Int(indices[triangle + 2])] - vertex0
        let pvec = cross(direction, edge2)
        let determinant = dot(edge1, pvec)
        guard abs(determinant) > epsilon else { return nil }

        let inverse = 1 / determinant
        let tvec = origin - vertex0
        let baryU = dot(tvec, pvec) * inverse
        guard baryU >= 0, baryU <= 1 else { return nil }

        let qvec = cross(tvec, edge1)
        let baryV = dot(direction, qvec) * inverse
        guard baryV >= 0, baryU + baryV <= 1 else { return nil }

        let distance = dot(edge2, qvec) * inverse
        guard distance > epsilon else { return nil }
        return Intersection(distance: distance, triangle: triangle, barycentric: [baryU, baryV])
    }
}

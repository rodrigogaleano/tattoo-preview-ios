import simd
import Testing
@testable import TattooPreview

struct MeshHitTesterTests {
    /// Quad de 1 m × 1 m no plano z = `depth`, de (-0.5, -0.5) a (0.5, 0.5), com UV 0–1.
    private func quad(depth: Float = 0, uvOffset: Float = 0) -> (positions: [SIMD3<Float>], uvs: [SIMD2<Float>]) {
        let positions: [SIMD3<Float>] = [[-0.5, -0.5, depth], [0.5, -0.5, depth], [0.5, 0.5, depth], [-0.5, 0.5, depth]]
        let uvs: [SIMD2<Float>] = [[0, 0], [1, 0], [1, 1], [0, 1]].map { $0 + SIMD2(repeating: uvOffset) }
        return (positions, uvs)
    }

    private let quadIndices: [UInt32] = [0, 1, 2, 0, 2, 3]

    private func tester() -> MeshHitTester {
        let quad = quad()
        return MeshHitTester(positions: quad.positions, uvs: quad.uvs, indices: quadIndices)
    }

    @Test func rayThroughCenterHitsMiddleUV() throws {
        let hit = try #require(tester().hit(origin: [0, 0, 2], direction: [0, 0, -1]))

        #expect(abs(hit.uv.x - 0.5) < 1e-5)
        #expect(abs(hit.uv.y - 0.5) < 1e-5)
        #expect(abs(hit.distance - 2) < 1e-5)
    }

    @Test func rayNearCornerInterpolatesUV() throws {
        let hit = try #require(tester().hit(origin: [0.3, -0.4, 1], direction: [0, 0, -1]))

        #expect(abs(hit.uv.x - 0.8) < 1e-5)
        #expect(abs(hit.uv.y - 0.1) < 1e-5)
    }

    @Test func rayOutsideMeshMisses() {
        #expect(tester().hit(origin: [2, 2, 1], direction: [0, 0, -1]) == nil)
        #expect(tester().hit(origin: [0, 0, 1], direction: [0, 0, 1]) == nil)
    }

    @Test func nearestSurfaceWins() throws {
        let back = quad(depth: 0)
        let front = quad(depth: 0.5, uvOffset: 10)
        let tester = MeshHitTester(
            positions: back.positions + front.positions,
            uvs: back.uvs + front.uvs,
            indices: quadIndices + quadIndices.map { $0 + 4 }
        )

        let hit = try #require(tester.hit(origin: [0, 0, 2], direction: [0, 0, -1]))

        #expect(hit.uv.x > 10)
        #expect(abs(hit.position.z - 0.5) < 1e-5)
    }

    @Test func uvDensityMatchesQuadMapping() throws {
        let hit = try #require(tester().hit(origin: [0, 0, 1], direction: [0, 0, -1]))

        #expect(abs(hit.uvUnitsPerMeter - 1) < 1e-5)
    }

    @Test func blendShapeOffsetsMoveHitSurface() throws {
        let quad = quad()
        let mesh = DeformableMesh(
            positions: quad.positions,
            uvs: quad.uvs,
            indices: quadIndices,
            blendShapeOffsets: ["weight_heavy": Array(repeating: [0, 0, 0.2], count: 4)],
            transform: matrix_identity_float4x4
        )

        let tester = mesh.hitTester(weights: ["weight_heavy": 0.5])

        let hit = try #require(tester.hit(origin: [0, 0, 1], direction: [0, 0, -1]))

        #expect(abs(hit.position.z - 0.1) < 1e-5)
    }
}

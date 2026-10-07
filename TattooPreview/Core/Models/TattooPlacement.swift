import Foundation

nonisolated struct TattooPlacement: Equatable, Codable {
    /// Origem embaixo à esquerda (convenção USD).
    var uv: SIMD2<Float>
    /// Largura em unidades de UV.
    var size: Float
    var rotation: Float
    var opacity: Float
}

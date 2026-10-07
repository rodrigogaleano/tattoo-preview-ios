import Foundation

nonisolated struct TattooPlacement: Equatable, Codable {
    /// Centro da tatuagem no espaço UV da textura de pele (origem embaixo à esquerda, convenção USD).
    var uv: SIMD2<Float>
    /// Largura da tatuagem em unidades de UV.
    var size: Float
    /// Rotação em radianos, sentido anti-horário no espaço UV.
    var rotation: Float
    var opacity: Float
}

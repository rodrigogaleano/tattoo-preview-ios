import CoreGraphics
import Foundation
import Testing
@testable import TattooPreview

struct TattooCompositorTests {
    private let size = 64

    private func blackSquare() throws -> CGImage {
        let context = try #require(CGContext(
            data: nil, width: 4, height: 4, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        return try #require(context.makeImage())
    }

    /// Valor do canal vermelho no pixel cujo centro fica em `uv` (V de baixo para cima).
    private func red(in image: CGImage, at uv: SIMD2<Float>) throws -> UInt8 {
        let data = try #require(image.dataProvider?.data as Data?)
        let column = Int(uv.x * Float(image.width))
        let row = image.height - 1 - Int(uv.y * Float(image.height))
        return data[row * image.bytesPerRow + column * image.bitsPerPixel / 8]
    }

    private func compose(uv: SIMD2<Float>, opacity: Float = 1) throws -> CGImage {
        let placement = TattooPlacement(uv: uv, size: 0.25, rotation: 0, opacity: opacity)
        return try #require(TattooCompositor.compose(tattoo: try blackSquare(), placement: placement, size: size))
    }

    @Test func darkensPlacementAndKeepsRestWhite() throws {
        let image = try compose(uv: [0.5, 0.5])

        #expect(try red(in: image, at: [0.5, 0.5]) < 10)
        #expect(try red(in: image, at: [0.05, 0.05]) == 255)
    }

    @Test func opacityBlendsTowardsWhite() throws {
        let value = try red(in: try compose(uv: [0.5, 0.5], opacity: 0.5), at: [0.5, 0.5])

        #expect((110...145).contains(value))
    }

    @Test func vCoordinateGrowsUpwards() throws {
        let image = try compose(uv: [0.25, 0.8])

        #expect(try red(in: image, at: [0.25, 0.8]) < 10)
        #expect(try red(in: image, at: [0.25, 0.2]) == 255)
    }
}

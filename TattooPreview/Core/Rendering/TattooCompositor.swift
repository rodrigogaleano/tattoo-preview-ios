import CoreGraphics
import Foundation

/// Compõe a tatuagem sobre uma textura de pele neutra (branca) em multiply.
/// O tom de pele entra depois, como tint do material: branco × tinta × tom = pele × tinta.
nonisolated enum TattooCompositor {
    static func compose(tattoo: CGImage, placement: TattooPlacement, size: Int) -> CGImage? {
        guard let context = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        let extent = CGFloat(size)
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: extent, height: extent))

        // CGContext tem origem embaixo à esquerda, igual ao UV do USD: sem inverter V.
        let width = CGFloat(placement.size) * extent
        let height = width * CGFloat(tattoo.height) / CGFloat(tattoo.width)
        context.translateBy(x: CGFloat(placement.uv.x) * extent, y: CGFloat(placement.uv.y) * extent)
        context.rotate(by: CGFloat(placement.rotation))
        context.setBlendMode(.multiply)
        context.setAlpha(CGFloat(placement.opacity))
        context.interpolationQuality = .high
        context.draw(tattoo, in: CGRect(x: -width / 2, y: -height / 2, width: width, height: height))

        return context.makeImage()
    }
}

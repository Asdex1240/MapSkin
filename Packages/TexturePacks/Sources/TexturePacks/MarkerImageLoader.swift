import CoreGraphics
import Foundation
import ImageIO

public struct MarkerImageLoader: Sendable {
    public static let displaySize = 36.0

    public let screenScale: Double

    public init(screenScale: Double) {
        self.screenScale = screenScale
    }

    public func loadMarker(of pack: TexturePack) -> TextureImage? {
        guard
            let url = pack.markerURL,
            let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
            image.width > 0
        else { return nil }
        let prepared = prepared(image, filtering: pack.manifest.filtering)
        return TextureImage(cgImage: prepared, scale: Double(prepared.width) / Self.displaySize)
    }

    private func prepared(_ image: CGImage, filtering: TextureFiltering) -> CGImage {
        guard filtering == .pixelated else { return image }
        let targetPixels = Self.displaySize * screenScale
        let factor = max(1, Int((targetPixels / Double(image.width)).rounded(.up)))
        return PixelArtScaler.upscale(image, by: factor) ?? image
    }
}

import CoreGraphics
import Foundation
import ImageIO

public struct TextureSetLoader: Sendable {
    public let screenScale: Double

    public init(screenScale: Double) {
        self.screenScale = screenScale
    }

    public func loadTextures(of pack: TexturePack, for appearance: MapAppearance) throws -> [TextureKind: TextureImage] {
        var textures: [TextureKind: TextureImage] = [:]
        for kind in TextureKind.allCases {
            let image = try sourceImage(of: kind, in: pack, for: appearance)
            textures[kind] = prepared(image, filtering: pack.manifest.filtering)
        }
        return textures
    }

    private func sourceImage(of kind: TextureKind, in pack: TexturePack, for appearance: MapAppearance) throws -> CGImage {
        if let url = pack.textureURL(for: kind, appearance: appearance) {
            return try readImage(at: url, kind: kind)
        }
        guard appearance == .night, let dayURL = pack.textureURL(for: kind, appearance: .day) else {
            throw TexturePackError.textureNotFound(kind)
        }
        guard let nightImage = NightTextureFilter.apply(to: try readImage(at: dayURL, kind: kind)) else {
            throw TexturePackError.unreadableTexture(kind)
        }
        return nightImage
    }

    private func readImage(at url: URL, kind: TextureKind) throws -> CGImage {
        guard
            let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { throw TexturePackError.unreadableTexture(kind) }
        return image
    }

    private func prepared(_ image: CGImage, filtering: TextureFiltering) -> TextureImage {
        switch filtering {
        case .smooth:
            return TextureImage(cgImage: image, scale: screenScale)
        case .pixelated:
            let factor = max(1, Int(screenScale.rounded(.up)))
            guard let upscaled = PixelArtScaler.upscale(image, by: factor) else {
                return TextureImage(cgImage: image, scale: 1)
            }
            return TextureImage(cgImage: upscaled, scale: Double(factor))
        }
    }
}

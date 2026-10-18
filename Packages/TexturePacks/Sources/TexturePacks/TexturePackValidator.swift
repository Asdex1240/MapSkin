import Foundation
import ImageIO
import UniformTypeIdentifiers

enum TexturePackValidator {
    private static let acceptedImageTypes: Set<String> = [UTType.png.identifier, UTType.jpeg.identifier]

    static func validatedManifest(ofPackAt root: URL) throws -> TexturePackManifest {
        let manifest = try manifest(at: root.appending(path: TexturePackManifest.fileName))
        let pack = TexturePack(id: root.lastPathComponent, manifest: manifest, directoryURL: root)
        var textureCount = 0
        for appearance in MapAppearance.allCases {
            for kind in TextureKind.allCases {
                guard let url = pack.textureURL(for: kind, appearance: appearance) else { continue }
                try validateImage(at: url, name: "\(appearance.rawValue)/\(url.lastPathComponent)")
                textureCount += 1
            }
        }
        guard textureCount > 0 else { throw TexturePackImportError.noTextures }
        if let markerURL = pack.markerURL {
            try validateMarker(at: markerURL)
        }
        return manifest
    }

    private static func manifest(at url: URL) throws -> TexturePackManifest {
        guard FileManager.default.fileExists(atPath: url.filePath) else {
            throw TexturePackImportError.manifestNotFound
        }
        let manifest: TexturePackManifest
        do {
            manifest = try TexturePackManifest.decode(from: Data(contentsOf: url))
        } catch {
            throw TexturePackImportError.invalidManifest
        }
        guard manifest.formatVersion == TexturePackLimits.supportedFormatVersion else {
            throw TexturePackImportError.unsupportedFormatVersion(manifest.formatVersion)
        }
        return manifest
    }

    private static func validateMarker(at url: URL) throws {
        guard
            let size = pixelSize(at: url, acceptedTypes: [UTType.png.identifier]),
            size.width == size.height,
            TexturePackLimits.markerSideRange.contains(size.width)
        else { throw TexturePackImportError.invalidMarker }
    }

    private static func pixelSize(at url: URL, acceptedTypes: Set<String>) -> (width: Int, height: Int)? {
        guard
            let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let type = CGImageSourceGetType(source) as String?,
            acceptedTypes.contains(type),
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
            let width = properties[kCGImagePropertyPixelWidth] as? Int,
            let height = properties[kCGImagePropertyPixelHeight] as? Int
        else { return nil }
        return (width, height)
    }

    private static func validateImage(at url: URL, name: String) throws {
        guard let (width, height) = pixelSize(at: url, acceptedTypes: acceptedImageTypes) else {
            throw TexturePackImportError.invalidImage(name)
        }
        guard width == height else { throw TexturePackImportError.imageNotSquare(name) }
        guard TexturePackLimits.imageSideRange.contains(width) else {
            throw TexturePackImportError.imageSizeOutOfRange(name)
        }
    }
}

import Foundation
import TexturePacks

struct TemporaryTexturePack {
    let directoryURL: URL

    init(
        filtering: TextureFiltering,
        textureSize: Int,
        appearances: [MapAppearance],
        omitting omitted: Set<TextureKind> = []
    ) throws {
        directoryURL = FileManager.default.temporaryDirectory.appending(path: "TexturePacksTests-\(UUID().uuidString)")
        try writeManifest(filtering: filtering)
        for appearance in appearances {
            let variantURL = directoryURL.appending(path: appearance.rawValue)
            try FileManager.default.createDirectory(at: variantURL, withIntermediateDirectories: true)
            for kind in TextureKind.allCases where !omitted.contains(kind) {
                let image = try TestImages.solid(RGBAPixel(red: 120, green: 200, blue: 90), size: textureSize)
                try TestImages.writePNG(image, to: variantURL.appending(path: "\(kind.rawValue).png"))
            }
        }
    }

    func remove() {
        try? FileManager.default.removeItem(at: directoryURL)
    }

    private func writeManifest(filtering: TextureFiltering) throws {
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let manifest = TexturePackManifest(formatVersion: 1, name: "Test", author: "Tests", filtering: filtering)
        try JSONEncoder().encode(manifest).write(to: directoryURL.appending(path: TexturePackManifest.fileName))
    }
}

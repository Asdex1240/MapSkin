import Foundation

enum MissingTextureFiller {
    static func fill(_ pack: TexturePack, from defaultPack: TexturePack) throws {
        let fileManager = FileManager.default
        for kind in TextureKind.allCases where pack.textureURL(for: kind, appearance: .day) == nil {
            for appearance in MapAppearance.allCases where pack.textureURL(for: kind, appearance: appearance) == nil {
                guard let source = defaultPack.textureURL(for: kind, appearance: appearance) else { continue }
                let variantDirectory = pack.directoryURL
                    .appending(path: appearance.rawValue, directoryHint: .isDirectory)
                try fileManager.createDirectory(at: variantDirectory, withIntermediateDirectories: true)
                try fileManager.copyItem(at: source, to: variantDirectory.appending(path: source.lastPathComponent))
            }
        }
    }
}

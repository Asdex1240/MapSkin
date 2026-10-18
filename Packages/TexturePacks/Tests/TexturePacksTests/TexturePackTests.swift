import Foundation
import Testing
import TexturePacks

struct TexturePackTests {
    @Test func loadsBundledDefaultPack() throws {
        let pack = try TexturePack.load(from: BundledTexturePacks.packURL(named: BundledTexturePacks.defaultPackName))

        #expect(pack.id == BundledTexturePacks.defaultPackName)
        #expect(pack.manifest.filtering == .smooth)
    }

    @Test func findsTextureForEveryKind() throws {
        let pack = try TexturePack.load(from: BundledTexturePacks.packURL(named: BundledTexturePacks.defaultPackName))

        for kind in TextureKind.allCases {
            #expect(pack.textureURL(for: kind, appearance: .day) != nil)
        }
    }

    @Test func rejectsDirectoryWithoutManifest() {
        let directoryURL = FileManager.default.temporaryDirectory.appending(path: "Empty-\(UUID().uuidString)")

        #expect(throws: TexturePackError.manifestNotFound) {
            try TexturePack.load(from: directoryURL)
        }
    }

    @Test func rejectsInvalidManifest() throws {
        let directoryURL = FileManager.default.temporaryDirectory.appending(path: "Invalid-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }
        try Data("{ \"name\": 3 }".utf8).write(to: directoryURL.appending(path: TexturePackManifest.fileName))

        #expect(throws: TexturePackError.invalidManifest) {
            try TexturePack.load(from: directoryURL)
        }
    }
}

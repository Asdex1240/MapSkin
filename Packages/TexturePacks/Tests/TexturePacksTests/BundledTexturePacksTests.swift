import Foundation
import Testing
import TexturePacks

struct BundledTexturePacksTests {
    @Test func includesDefaultPack() throws {
        #expect(try BundledTexturePacks.packNames().contains(BundledTexturePacks.defaultPackName))
    }

    @Test(arguments: try BundledTexturePacks.packNames())
    func bundledPackHasValidManifest(named name: String) throws {
        let manifestURL = BundledTexturePacks.packURL(named: name).appending(path: TexturePackManifest.fileName)

        let manifest = try TexturePackManifest.decode(from: Data(contentsOf: manifestURL))

        #expect(manifest.formatVersion == 1)
        #expect(manifest.colors?.day != nil)
        #expect(manifest.colors?.night != nil)
    }

    @Test(arguments: try BundledTexturePacks.packNames())
    func bundledPackHasEveryTextureForDayAndNight(named name: String) {
        let packURL = BundledTexturePacks.packURL(named: name)

        for variant in ["day", "night"] {
            for kind in TextureKind.allCases {
                let textureURL = packURL.appending(path: "\(variant)/\(kind.rawValue).png")
                let label = "\(name)/\(variant)/\(kind.rawValue)"
                #expect(FileManager.default.fileExists(atPath: textureURL.path(percentEncoded: false)), "\(label)")
            }
        }
    }
}

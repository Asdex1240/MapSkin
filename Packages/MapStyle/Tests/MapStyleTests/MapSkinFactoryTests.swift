import Foundation
import MapStyle
import Testing
import TexturePacks

struct MapSkinFactoryTests {
    private let factory = MapSkinFactory(
        styleBuilder: MapStyleBuilder(
            tilesURL: URL(string: "https://tiles.example.com/planet")!,
            glyphsURL: "https://tiles.example.com/fonts/{fontstack}/{range}.pbf",
            labelLanguage: "en"
        )
    )

    @Test(arguments: MapAppearance.allCases)
    func buildsSkinWithAllTexturesForBundledPack(appearance: MapAppearance) async throws {
        let pack = try TexturePack.load(from: BundledTexturePacks.packURL(named: BundledTexturePacks.defaultPackName))

        let skin = try await factory.makeSkin(pack: pack, appearance: appearance, screenScale: 3)

        #expect(Set(skin.images.keys) == Set(TextureKind.allCases.map(\.styleImageName)))
        #expect(skin.id.contains(appearance.rawValue))
        #expect(!skin.styleJSON.isEmpty)
    }

    @Test func usesPackColorsInStyle() async throws {
        let pack = try TexturePack.load(from: BundledTexturePacks.packURL(named: BundledTexturePacks.defaultPackName))
        let nightBackground = try #require(pack.manifest.colors?.night?.background)

        let skin = try await factory.makeSkin(pack: pack, appearance: .night, screenScale: 2)

        #expect(skin.styleJSON.contains(nightBackground.uppercased()))
    }
}

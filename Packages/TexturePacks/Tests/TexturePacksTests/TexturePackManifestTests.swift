import Foundation
import Testing
import TexturePacks

struct TexturePackManifestTests {
    @Test func decodesCompleteManifest() throws {
        let manifest = try TexturePackManifest.decode(from: fixture(named: "complete-pack"))

        #expect(manifest.formatVersion == 1)
        #expect(manifest.name == "Mi paquete")
        #expect(manifest.author == "Nombre del autor")
        #expect(manifest.filtering == .smooth)
        #expect(manifest.colors?.day?.route == "#1A73E8")
        #expect(manifest.colors?.night?.roadCasing == "#2C323B")
    }

    @Test func decodesManifestWithoutOptionalFields() throws {
        let json = #"{ "formatVersion": 1, "name": "Minimal", "author": "Someone", "filtering": "pixelated" }"#

        let manifest = try TexturePackManifest.decode(from: Data(json.utf8))

        #expect(manifest.filtering == .pixelated)
        #expect(manifest.description == nil)
        #expect(manifest.license == nil)
        #expect(manifest.colors == nil)
    }

    @Test func decodesPartialPalette() throws {
        let json = #"""
        { "formatVersion": 1, "name": "Partial", "author": "Someone", "filtering": "smooth",
          "colors": { "day": { "route": "#FF0000" } } }
        """#

        let manifest = try TexturePackManifest.decode(from: Data(json.utf8))

        #expect(manifest.colors?.day == PaletteOverrides(route: "#FF0000"))
        #expect(manifest.colors?.night == nil)
    }

    @Test func rejectsManifestWithoutFiltering() {
        let json = #"{ "formatVersion": 1, "name": "No filtering", "author": "Someone" }"#

        #expect(throws: DecodingError.self) {
            try TexturePackManifest.decode(from: Data(json.utf8))
        }
    }

    @Test func rejectsUnknownFiltering() {
        let json = #"{ "formatVersion": 1, "name": "Blurry", "author": "Someone", "filtering": "blurry" }"#

        #expect(throws: DecodingError.self) {
            try TexturePackManifest.decode(from: Data(json.utf8))
        }
    }

    private func fixture(named name: String) throws -> Data {
        let url = try #require(Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures"))
        return try Data(contentsOf: url)
    }
}

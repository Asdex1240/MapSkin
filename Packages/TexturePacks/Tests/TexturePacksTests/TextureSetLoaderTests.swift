import Testing
import TexturePacks

struct TextureSetLoaderTests {
    @Test func loadsSmoothTexturesAtOriginalSizeWithScreenScale() throws {
        let fixture = try TemporaryTexturePack(filtering: .smooth, textureSize: 8, appearances: [.day])
        defer { fixture.remove() }
        let pack = try TexturePack.load(from: fixture.directoryURL)

        let textures = try TextureSetLoader(screenScale: 3).loadTextures(of: pack, for: .day)

        #expect(textures.count == TextureKind.allCases.count)
        let grass = try #require(textures[.grass])
        #expect(grass.cgImage.width == 8)
        #expect(grass.scale == 3)
    }

    @Test func upscalesPixelatedTexturesToScreenScale() throws {
        let fixture = try TemporaryTexturePack(filtering: .pixelated, textureSize: 4, appearances: [.day])
        defer { fixture.remove() }
        let pack = try TexturePack.load(from: fixture.directoryURL)

        let textures = try TextureSetLoader(screenScale: 3).loadTextures(of: pack, for: .day)

        let water = try #require(textures[.water])
        #expect(water.cgImage.width == 12)
        #expect(water.scale == 3)
    }

    @Test func generatesNightTexturesWhenMissing() throws {
        let fixture = try TemporaryTexturePack(filtering: .smooth, textureSize: 4, appearances: [.day])
        defer { fixture.remove() }
        let pack = try TexturePack.load(from: fixture.directoryURL)

        let day = try TextureSetLoader(screenScale: 2).loadTextures(of: pack, for: .day)
        let night = try TextureSetLoader(screenScale: 2).loadTextures(of: pack, for: .night)

        let dayPixel = try TestImages.pixel(of: try #require(day[.forest]).cgImage, x: 0, y: 0)
        let nightPixel = try TestImages.pixel(of: try #require(night[.forest]).cgImage, x: 0, y: 0)
        #expect(nightPixel.luminance < dayPixel.luminance)
    }

    @Test func failsWhenTextureIsMissing() throws {
        let fixture = try TemporaryTexturePack(
            filtering: .smooth,
            textureSize: 4,
            appearances: [.day],
            omitting: [.snow]
        )
        defer { fixture.remove() }
        let pack = try TexturePack.load(from: fixture.directoryURL)

        #expect(throws: TexturePackError.textureNotFound(.snow)) {
            try TextureSetLoader(screenScale: 2).loadTextures(of: pack, for: .day)
        }
    }
}

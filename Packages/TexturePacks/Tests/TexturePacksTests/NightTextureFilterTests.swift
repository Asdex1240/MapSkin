import Testing
@testable import TexturePacks

struct NightTextureFilterTests {
    @Test func darkensTexture() throws {
        let day = try TestImages.solid(RGBAPixel(red: 200, green: 220, blue: 160), size: 2)

        let night = try #require(NightTextureFilter.apply(to: day))

        let dayPixel = try TestImages.pixel(of: day, x: 0, y: 0)
        let nightPixel = try TestImages.pixel(of: night, x: 0, y: 0)
        #expect(nightPixel.luminance < dayPixel.luminance * 0.7)
    }

    @Test func tintsTowardsBlue() throws {
        let gray = try TestImages.solid(RGBAPixel(red: 180, green: 180, blue: 180), size: 2)

        let night = try #require(NightTextureFilter.apply(to: gray))

        let pixel = try TestImages.pixel(of: night, x: 1, y: 1)
        #expect(pixel.blue > pixel.green)
        #expect(pixel.green > pixel.red)
    }

    @Test func keepsDimensions() throws {
        let day = try TestImages.solid(RGBAPixel(red: 10, green: 20, blue: 30), size: 8)

        let night = try #require(NightTextureFilter.apply(to: day))

        #expect(night.width == 8)
        #expect(night.height == 8)
    }
}

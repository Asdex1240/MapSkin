import Testing
@testable import TexturePacks

struct PixelArtScalerTests {
    private let red = RGBAPixel(red: 255, green: 0, blue: 0)
    private let green = RGBAPixel(red: 0, green: 255, blue: 0)
    private let blue = RGBAPixel(red: 0, green: 0, blue: 255)
    private let white = RGBAPixel(red: 255, green: 255, blue: 255)

    @Test func multipliesDimensionsByFactor() throws {
        let source = try TestImages.make(rows: [[red, green], [blue, white]])

        let upscaled = try #require(PixelArtScaler.upscale(source, by: 3))

        #expect(upscaled.width == 6)
        #expect(upscaled.height == 6)
    }

    @Test func keepsHardEdgesBetweenPixels() throws {
        let source = try TestImages.make(rows: [[red, green], [blue, white]])

        let upscaled = try #require(PixelArtScaler.upscale(source, by: 3))

        #expect(try TestImages.pixel(of: upscaled, x: 0, y: 0) == TestImages.pixel(of: source, x: 0, y: 0))
        #expect(try TestImages.pixel(of: upscaled, x: 2, y: 2) == TestImages.pixel(of: source, x: 0, y: 0))
        #expect(try TestImages.pixel(of: upscaled, x: 3, y: 0) == TestImages.pixel(of: source, x: 1, y: 0))
        #expect(try TestImages.pixel(of: upscaled, x: 5, y: 5) == TestImages.pixel(of: source, x: 1, y: 1))
    }

    @Test func returnsSameImageForFactorOne() throws {
        let source = try TestImages.make(rows: [[red, green], [blue, white]])

        let upscaled = try #require(PixelArtScaler.upscale(source, by: 1))

        #expect(upscaled.width == 2)
    }
}

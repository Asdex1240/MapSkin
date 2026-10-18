import CoreGraphics
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers
@testable import TexturePacks

struct MarkerTests {
    @Test func importsPackWithValidMarker() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = try ImportFixtures.validArchive()
        builder.add(TexturePack.markerFileName, data: try ImportFixtures.png(size: 32))
        let archiveURL = fixtures.file(named: "marker.mapskin")
        try builder.write(to: archiveURL)

        let pack = try fixtures.importer().importPack(from: archiveURL)

        #expect(pack.markerURL != nil)
    }

    @Test(arguments: [8, 300])
    func rejectsMarkerOutsideSizeRange(size: Int) throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = try ImportFixtures.validArchive()
        builder.add(TexturePack.markerFileName, data: try ImportFixtures.png(size: size))
        let archiveURL = fixtures.file(named: "marker-size.mapskin")
        try builder.write(to: archiveURL)

        #expect(throws: TexturePackImportError.invalidMarker) {
            try fixtures.importer().importPack(from: archiveURL)
        }
    }

    @Test func rejectsNonSquareMarker() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = try ImportFixtures.validArchive()
        builder.add(TexturePack.markerFileName, data: try ImportFixtures.png(size: 32, height: 16))
        let archiveURL = fixtures.file(named: "marker-wide.mapskin")
        try builder.write(to: archiveURL)

        #expect(throws: TexturePackImportError.invalidMarker) {
            try fixtures.importer().importPack(from: archiveURL)
        }
    }

    @Test func rejectsMarkerThatIsNotPNG() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = try ImportFixtures.validArchive()
        builder.add(TexturePack.markerFileName, data: try Self.jpeg(size: 32))
        let archiveURL = fixtures.file(named: "marker-jpeg.mapskin")
        try builder.write(to: archiveURL)

        #expect(throws: TexturePackImportError.invalidMarker) {
            try fixtures.importer().importPack(from: archiveURL)
        }
    }

    @Test func importsPackWithoutMarker() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        let archiveURL = fixtures.file(named: "no-marker.mapskin")
        try ImportFixtures.validArchive().write(to: archiveURL)

        let pack = try fixtures.importer().importPack(from: archiveURL)

        #expect(pack.markerURL == nil)
        #expect(MarkerImageLoader(screenScale: 3).loadMarker(of: pack) == nil)
    }

    @Test func upscalesPixelatedMarkerToDisplaySize() throws {
        let pack = try Self.packWithMarker(filtering: .pixelated, size: 16)
        defer { try? FileManager.default.removeItem(at: pack.directoryURL) }

        let marker = try #require(MarkerImageLoader(screenScale: 3).loadMarker(of: pack))

        #expect(marker.cgImage.width == 112)
        #expect(abs(Double(marker.cgImage.width) / marker.scale - MarkerImageLoader.displaySize) < 0.01)
    }

    @Test func keepsSmoothMarkerPixelsAndScalesToDisplaySize() throws {
        let pack = try Self.packWithMarker(filtering: .smooth, size: 128)
        defer { try? FileManager.default.removeItem(at: pack.directoryURL) }

        let marker = try #require(MarkerImageLoader(screenScale: 3).loadMarker(of: pack))

        #expect(marker.cgImage.width == 128)
        #expect(abs(Double(marker.cgImage.width) / marker.scale - MarkerImageLoader.displaySize) < 0.01)
    }

    private static func packWithMarker(filtering: TextureFiltering, size: Int) throws -> TexturePack {
        let fixture = try TemporaryTexturePack(filtering: filtering, textureSize: 8, appearances: [.day])
        try ImportFixtures.png(size: size).write(to: fixture.directoryURL.appending(path: TexturePack.markerFileName))
        return try TexturePack.load(from: fixture.directoryURL)
    }

    private static func jpeg(size: Int) throws -> Data {
        let image = try TestImages.solid(RGBAPixel(red: 200, green: 30, blue: 30), size: size)
        let data = NSMutableData()
        let destination = try #require(
            CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)
        )
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
        return data as Data
    }
}

import Foundation
import Testing
@testable import TexturePacks

struct TexturePackImporterTests {
    @Test func installsValidArchive() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        let archiveURL = fixtures.file(named: "pack.mapskin")
        try ImportFixtures.validArchive().write(to: archiveURL)

        let pack = try fixtures.importer().importPack(from: archiveURL)

        #expect(pack.manifest.name == "Imported")
        #expect(pack.directoryURL.deletingLastPathComponent().standardizedFileURL
            == fixtures.installDirectory.standardizedFileURL)
        #expect(pack.textureURL(for: .grass, appearance: .day) != nil)
    }

    @Test func fillsMissingTexturesFromDefaultPack() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        let archiveURL = fixtures.file(named: "partial.zip")
        try ImportFixtures.validArchive(kinds: [.grass]).write(to: archiveURL)

        let pack = try fixtures.importer().importPack(from: archiveURL)

        for kind in TextureKind.allCases {
            #expect(pack.textureURL(for: kind, appearance: .day) != nil, "\(kind)")
        }
        #expect(pack.textureURL(for: .snow, appearance: .night) != nil)
        #expect(pack.textureURL(for: .grass, appearance: .night) == nil)
    }

    @Test func completesPartialPackWhenInstallPathContainsSpaces() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        let archiveURL = fixtures.file(named: "spaced.mapskin")
        try ImportFixtures.validArchive(kinds: TextureKind.allCases.filter { $0 != .rock }).write(to: archiveURL)

        let pack = try fixtures.importer().importPack(from: archiveURL)

        #expect(pack.directoryURL.path(percentEncoded: false).contains("Application Support"))
        #expect(pack.textureURL(for: .grass, appearance: .day) != nil)
        #expect(pack.textureURL(for: .rock, appearance: .day) != nil)
    }

    @Test func acceptsArchiveWithTopLevelFolder() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        let archiveURL = fixtures.file(named: "nested.zip")
        try ImportFixtures.validArchive(prefix: "my-pack/").write(to: archiveURL)

        let pack = try fixtures.importer().importPack(from: archiveURL)

        #expect(pack.textureURL(for: .water, appearance: .day) != nil)
    }

    @Test func importsFolder() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        let folder = fixtures.file(named: "FolderPack")
        try FileManager.default.createDirectory(at: folder.appending(path: "day"), withIntermediateDirectories: true)
        try ImportFixtures.manifestData().write(to: folder.appending(path: "pack.json"))
        try ImportFixtures.png(size: 32).write(to: folder.appending(path: "day/forest.png"))

        let pack = try fixtures.importer().importPack(from: folder)

        #expect(pack.manifest.name == "Imported")
        #expect(FileManager.default.fileExists(atPath: folder.path(percentEncoded: false)))
    }

    @Test(arguments: ["../escaped.png", "day/../../escaped.png", "/tmp/escaped.png"])
    func rejectsZipSlip(maliciousPath: String) throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = try ImportFixtures.validArchive()
        builder.add(maliciousPath, data: try ImportFixtures.png(size: 16))
        let archiveURL = fixtures.file(named: "slip.zip")
        try builder.write(to: archiveURL)

        #expect(throws: TexturePackImportError.unsafePath) {
            try fixtures.importer().importPack(from: archiveURL)
        }
        let temporary = FileManager.default.temporaryDirectory
        let escapedFile = temporary.appending(path: "escaped.png")
        #expect(!FileManager.default.fileExists(atPath: escapedFile.path(percentEncoded: false)))
        #expect(!FileManager.default.fileExists(atPath: fixtures.installDirectory.path(percentEncoded: false)))
    }

    @Test func rejectsTooManyFiles() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = try ImportFixtures.validArchive()
        for index in 0..<TexturePackLimits.maximumFileCount {
            builder.add("extra/\(index).json", data: Data("{}".utf8))
        }
        let archiveURL = fixtures.file(named: "many.zip")
        try builder.write(to: archiveURL)

        #expect(throws: TexturePackImportError.tooManyFiles) {
            try fixtures.importer().importPack(from: archiveURL)
        }
    }

    @Test func rejectsPacksOverSizeLimit() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = try ImportFixtures.validArchive()
        builder.add("extra/padding.json", data: Data(count: TexturePackLimits.maximumTotalBytes))
        let archiveURL = fixtures.file(named: "large.zip")
        try builder.write(to: archiveURL)

        #expect(throws: TexturePackImportError.tooLarge) {
            try fixtures.importer().importPack(from: archiveURL)
        }
    }

    @Test func rejectsArchiveWithoutManifest() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = TestZipBuilder()
        builder.add("day/grass.png", data: try ImportFixtures.png(size: 16))
        let archiveURL = fixtures.file(named: "nomanifest.zip")
        try builder.write(to: archiveURL)

        #expect(throws: TexturePackImportError.manifestNotFound) {
            try fixtures.importer().importPack(from: archiveURL)
        }
    }

    @Test func rejectsUnsupportedFormatVersion() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = TestZipBuilder()
        builder.add("pack.json", data: ImportFixtures.manifestData(formatVersion: 2))
        builder.add("day/grass.png", data: try ImportFixtures.png(size: 16))
        let archiveURL = fixtures.file(named: "future.zip")
        try builder.write(to: archiveURL)

        #expect(throws: TexturePackImportError.unsupportedFormatVersion(2)) {
            try fixtures.importer().importPack(from: archiveURL)
        }
    }

    @Test func rejectsNonSquareImages() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = TestZipBuilder()
        builder.add("pack.json", data: ImportFixtures.manifestData())
        builder.add("day/grass.png", data: try ImportFixtures.png(size: 16, height: 32))
        let archiveURL = fixtures.file(named: "wide.zip")
        try builder.write(to: archiveURL)

        #expect(throws: TexturePackImportError.imageNotSquare("day/grass.png")) {
            try fixtures.importer().importPack(from: archiveURL)
        }
    }

    @Test(arguments: [4, 600])
    func rejectsImagesOutsideSizeRange(size: Int) throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = TestZipBuilder()
        builder.add("pack.json", data: ImportFixtures.manifestData())
        builder.add("day/water.png", data: try ImportFixtures.png(size: size))
        let archiveURL = fixtures.file(named: "size.zip")
        try builder.write(to: archiveURL)

        #expect(throws: TexturePackImportError.imageSizeOutOfRange("day/water.png")) {
            try fixtures.importer().importPack(from: archiveURL)
        }
    }

    @Test func rejectsFilesThatAreNotImages() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = TestZipBuilder()
        builder.add("pack.json", data: ImportFixtures.manifestData())
        builder.add("day/sand.png", data: Data("not an image".utf8))
        let archiveURL = fixtures.file(named: "fake.zip")
        try builder.write(to: archiveURL)

        #expect(throws: TexturePackImportError.invalidImage("day/sand.png")) {
            try fixtures.importer().importPack(from: archiveURL)
        }
    }

    @Test func ignoresUnsupportedFileTypes() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = try ImportFixtures.validArchive()
        builder.add("install.sh", data: Data("echo hi".utf8))
        let archiveURL = fixtures.file(named: "script.zip")
        try builder.write(to: archiveURL)

        let pack = try fixtures.importer().importPack(from: archiveURL)

        let script = pack.directoryURL.appending(path: "install.sh")
        #expect(!FileManager.default.fileExists(atPath: script.path(percentEncoded: false)))
    }

    @Test func rejectsPackWithoutTextures() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        var builder = TestZipBuilder()
        builder.add("pack.json", data: ImportFixtures.manifestData())
        let archiveURL = fixtures.file(named: "empty.zip")
        try builder.write(to: archiveURL)

        #expect(throws: TexturePackImportError.noTextures) {
            try fixtures.importer().importPack(from: archiveURL)
        }
    }
}

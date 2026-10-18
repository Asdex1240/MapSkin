import Foundation
import Testing
@testable import TexturePacks

struct ZipArchiveTests {
    @Test func readsStoredEntries() throws {
        var builder = TestZipBuilder()
        builder.add("pack.json", data: Data("{}".utf8))
        builder.add("day/grass.png", data: Data([1, 2, 3]))

        let archive = try ZipArchive(data: builder.build())

        #expect(archive.entries.map(\.path) == ["pack.json", "day/grass.png"])
        #expect(try archive.contents(of: archive.entries[1]) == Data([1, 2, 3]))
    }

    @Test func readsDeflatedArchiveCreatedBySystem() throws {
        let fixtures = try ImportFixtures()
        defer { fixtures.remove() }
        let folder = fixtures.file(named: "Folder")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let text = Data(String(repeating: "MapSkin ", count: 500).utf8)
        try text.write(to: folder.appending(path: "notes.json"))
        let pack = TexturePack(id: "folder", manifest: TexturePackManifest(
            formatVersion: 1, name: "Folder", author: "Tests", filtering: .smooth
        ), directoryURL: folder)

        let archiveURL = try TexturePackTemplate.makeArchive(basedOn: pack, in: fixtures.file(named: "Output"))
        let archive = try ZipArchive(data: Data(contentsOf: archiveURL))

        let notes = try #require(archive.entries.first { $0.path.hasSuffix("notes.json") })
        #expect(notes.method == .deflated)
        #expect(try archive.contents(of: notes) == text)
    }

    @Test func rejectsCorruptedContents() throws {
        var builder = TestZipBuilder()
        builder.add("pack.json", data: Data("{\"a\":1}".utf8))
        var data = builder.build()
        let contentOffset = 30 + "pack.json".utf8.count
        data[contentOffset] = UInt8(ascii: "X")

        let archive = try ZipArchive(data: data)

        #expect(throws: TexturePackImportError.unreadableArchive) {
            try archive.contents(of: archive.entries[0])
        }
    }

    @Test func rejectsDataThatIsNotAnArchive() {
        #expect(throws: TexturePackImportError.unreadableArchive) {
            try ZipArchive(data: Data("not a zip file".utf8))
        }
    }
}

import Foundation
import Testing
@testable import TexturePacks

@MainActor
struct TexturePackLibraryTests {
    @Test func startsWithDefaultPackActive() throws {
        let context = try LibraryContext()
        defer { context.remove() }

        let library = try context.makeLibrary()

        #expect(library.activePack.id == BundledTexturePacks.defaultPackName)
        #expect(!library.isRemovable(library.defaultPack))
    }

    @Test func activatesImportedPack() async throws {
        let context = try LibraryContext()
        defer { context.remove() }
        let library = try context.makeLibrary()

        let pack = try await library.importPack(from: context.archiveURL())

        #expect(library.activePack.id == pack.id)
        #expect(library.packs.contains { $0.id == pack.id })
        #expect(library.isRemovable(pack))
    }

    @Test func keepsImportedPacksAndSelectionAcrossLaunches() async throws {
        let context = try LibraryContext()
        defer { context.remove() }
        let pack = try await context.makeLibrary().importPack(from: context.archiveURL())

        let reloaded = try context.makeLibrary()

        #expect(reloaded.activePack.id == pack.id)
    }

    @Test func fallsBackToDefaultWhenActivePackIsDeleted() async throws {
        let context = try LibraryContext()
        defer { context.remove() }
        let library = try context.makeLibrary()
        let pack = try await library.importPack(from: context.archiveURL())

        try library.delete(pack)

        #expect(library.activePack.id == BundledTexturePacks.defaultPackName)
        #expect(!FileManager.default.fileExists(atPath: pack.directoryURL.path(percentEncoded: false)))
    }

    @Test func neverDeletesBundledPacks() throws {
        let context = try LibraryContext()
        defer { context.remove() }
        let library = try context.makeLibrary()

        try library.delete(library.defaultPack)

        #expect(library.packs.contains { $0.id == BundledTexturePacks.defaultPackName })
        #expect(FileManager.default.fileExists(atPath: library.defaultPack.directoryURL.path(percentEncoded: false)))
    }

    @Test func templateCanBeImportedBack() async throws {
        let context = try LibraryContext()
        defer { context.remove() }
        let library = try context.makeLibrary()
        let template = try TexturePackTemplate.makeArchive(
            basedOn: library.defaultPack,
            in: context.fixtures.file(named: "Template")
        )

        let pack = try await library.importPack(from: template)

        #expect(template.pathExtension == "mapskin")
        #expect(pack.manifest.name == "My Pack")
    }
}

@MainActor
private struct LibraryContext {
    let fixtures: ImportFixtures
    private let suiteName = "TexturePackLibraryTests-\(UUID().uuidString)"

    init() throws {
        fixtures = try ImportFixtures()
    }

    func makeLibrary() throws -> TexturePackLibrary {
        try TexturePackLibrary(
            defaults: UserDefaults(suiteName: suiteName) ?? .standard,
            installDirectory: fixtures.installDirectory
        )
    }

    func archiveURL() throws -> URL {
        let url = fixtures.file(named: "\(UUID().uuidString).mapskin")
        try ImportFixtures.validArchive().write(to: url)
        return url
    }

    func remove() {
        fixtures.remove()
        UserDefaults().removePersistentDomain(forName: suiteName)
    }
}

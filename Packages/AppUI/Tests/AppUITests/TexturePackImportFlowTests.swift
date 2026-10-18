import Foundation
import Testing
import TexturePacks
@testable import AppUI

@MainActor
struct TexturePackImportFlowTests {
    @Test func asksForNoticeBeforeFirstImport() throws {
        let context = try FlowContext()
        defer { context.remove() }

        context.flow.chooseFile()

        #expect(context.flow.pendingAction == .choosePack)
        #expect(!context.flow.isPickerPresented)
    }

    @Test func opensPickerAfterNoticeIsAccepted() async throws {
        let context = try FlowContext()
        defer { context.remove() }
        context.flow.chooseFile()

        await context.flow.acceptNotice()

        #expect(context.flow.pendingAction == nil)
        #expect(context.flow.isPickerPresented)
    }

    @Test func skipsNoticeOnceAccepted() async throws {
        let context = try FlowContext()
        defer { context.remove() }
        context.flow.chooseFile()
        await context.flow.acceptNotice()
        context.flow.isPickerPresented = false

        context.flow.chooseFile()

        #expect(context.flow.isPickerPresented)
        #expect(context.flow.pendingAction == nil)
    }

    @Test func importsOpenedFileAfterNotice() async throws {
        let context = try FlowContext()
        defer { context.remove() }
        let archive = try context.templateArchive()

        await context.flow.receive(archive)
        await context.flow.acceptNotice()

        #expect(context.flow.outcome == .installed(name: "My Pack"))
        #expect(context.library.activePack.manifest.name == "My Pack")
    }

    @Test func reportsInvalidFiles() async throws {
        let context = try FlowContext()
        defer { context.remove() }
        let bogus = context.directory.appending(path: "bogus.mapskin")
        try Data("not a pack".utf8).write(to: bogus)

        await context.flow.importPack(from: bogus)

        #expect(context.flow.outcome == .failed(message: TexturePackImportError.unreadableArchive.localizedDescription))
        #expect(context.library.activePack.id == context.library.defaultPack.id)
    }

    @Test func declinedNoticeDoesNotImport() async throws {
        let context = try FlowContext()
        defer { context.remove() }
        let bundledPackCount = context.library.packs.count

        await context.flow.receive(try context.templateArchive())
        context.flow.declineNotice()

        #expect(context.flow.pendingAction == nil)
        #expect(context.library.packs.count == bundledPackCount)
    }
}

@MainActor
private struct FlowContext {
    let directory: URL
    let library: TexturePackLibrary
    let flow: TexturePackImportFlow
    private let suiteName: String

    init() throws {
        suiteName = "TexturePackImportFlowTests-\(UUID().uuidString)"
        directory = FileManager.default.temporaryDirectory.appending(path: suiteName)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        library = try TexturePackLibrary(defaults: defaults, installDirectory: directory.appending(path: "Installed"))
        flow = TexturePackImportFlow(library: library, defaults: defaults)
    }

    func templateArchive() throws -> URL {
        try TexturePackTemplate.makeArchive(basedOn: library.defaultPack, in: directory.appending(path: "Template"))
    }

    func remove() {
        try? FileManager.default.removeItem(at: directory)
        UserDefaults().removePersistentDomain(forName: suiteName)
    }
}

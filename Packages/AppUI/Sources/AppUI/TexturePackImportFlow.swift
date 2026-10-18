import Foundation
import Observation
import OSLog
import TexturePacks

@MainActor
@Observable
final class TexturePackImportFlow {
    enum PendingAction: Equatable {
        case choosePack
        case importFile(URL)
    }

    enum Outcome: Equatable {
        case installed(name: String)
        case failed(message: String)
    }

    private static let noticeAcceptedKey = "texturePacks.importNoticeAccepted"

    var isPickerPresented = false
    private(set) var pendingAction: PendingAction?
    private(set) var outcome: Outcome?
    private(set) var isImporting = false
    private(set) var templateURL: URL?

    let library: TexturePackLibrary
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let logger = Logger(subsystem: "MapSkin", category: "TexturePackImportFlow")

    init(library: TexturePackLibrary, defaults: UserDefaults) {
        self.library = library
        self.defaults = defaults
    }

    private var hasAcceptedNotice: Bool {
        defaults.bool(forKey: Self.noticeAcceptedKey)
    }

    func chooseFile() {
        if hasAcceptedNotice {
            isPickerPresented = true
        } else {
            pendingAction = .choosePack
        }
    }

    func receive(_ url: URL) async {
        if hasAcceptedNotice {
            await importPack(from: url)
        } else {
            pendingAction = .importFile(url)
        }
    }

    func acceptNotice() async {
        defaults.set(true, forKey: Self.noticeAcceptedKey)
        let action = pendingAction
        pendingAction = nil
        switch action {
        case .choosePack: isPickerPresented = true
        case .importFile(let url): await importPack(from: url)
        case nil: break
        }
    }

    func declineNotice() {
        if case .importFile(let url) = pendingAction {
            removeInboxCopy(of: url)
        }
        pendingAction = nil
    }

    func importPack(from url: URL) async {
        isImporting = true
        defer {
            isImporting = false
            removeInboxCopy(of: url)
        }
        do {
            let pack = try await library.importPack(from: url)
            outcome = .installed(name: pack.manifest.name)
        } catch {
            outcome = .failed(message: error.localizedDescription)
        }
    }

    func handlePickerFailure(_ error: Error) {
        outcome = .failed(message: error.localizedDescription)
    }

    func delete(_ pack: TexturePack) {
        do {
            try library.delete(pack)
        } catch {
            outcome = .failed(message: error.localizedDescription)
        }
    }

    func dismissOutcome() {
        outcome = nil
    }

    func prepareTemplate() async {
        guard templateURL == nil else { return }
        let basePack = library.defaultPack
        let directory = FileManager.default.temporaryDirectory.appending(path: "Template", directoryHint: .isDirectory)
        do {
            templateURL = try await Task.detached(priority: .utility) {
                try TexturePackTemplate.makeArchive(basedOn: basePack, in: directory)
            }.value
        } catch {
            logger.error("Could not create the texture pack template: \(error.localizedDescription)")
        }
    }

    private func removeInboxCopy(of url: URL) {
        guard url.deletingLastPathComponent().lastPathComponent == "Inbox" else { return }
        try? FileManager.default.removeItem(at: url)
    }
}

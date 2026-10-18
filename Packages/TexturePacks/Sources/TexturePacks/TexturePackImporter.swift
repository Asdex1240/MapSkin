import Foundation
import OSLog

public struct TexturePackImporter: Sendable {
    private let defaultPack: TexturePack
    private let installDirectory: URL
    private let logger = Logger(subsystem: "MapSkin", category: "TexturePackImporter")

    public init(defaultPack: TexturePack, installDirectory: URL) {
        self.defaultPack = defaultPack
        self.installDirectory = installDirectory
    }

    public func importPack(from url: URL) throws -> TexturePack {
        let isAccessingSecurityScope = url.startAccessingSecurityScopedResource()
        defer {
            if isAccessingSecurityScope { url.stopAccessingSecurityScopedResource() }
        }
        let staging = try PackStaging()
        defer { staging.remove() }
        do {
            try stage(url, in: staging)
            return try install(packAt: staging.packRoot())
        } catch let error as TexturePackImportError {
            logger.error("Rejected texture pack \(url.lastPathComponent): \(String(describing: error))")
            throw error
        } catch {
            logger.error("Could not read texture pack \(url.filePath, privacy: .private): \(error)")
            throw TexturePackImportError.unreadableArchive
        }
    }

    private func stage(_ url: URL, in staging: PackStaging) throws {
        if try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true {
            try staging.stage(directoryAt: url)
        } else {
            try staging.stage(archiveAt: url)
        }
    }

    private func install(packAt root: URL) throws -> TexturePack {
        let manifest = try TexturePackValidator.validatedManifest(ofPackAt: root)
        let destination = installDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: installDirectory, withIntermediateDirectories: true)
        try FileManager.default.moveItem(at: root, to: destination)
        let pack = TexturePack(id: destination.lastPathComponent, manifest: manifest, directoryURL: destination)
        do {
            try MissingTextureFiller.fill(pack, from: defaultPack)
        } catch {
            try? FileManager.default.removeItem(at: destination)
            throw error
        }
        return pack
    }
}

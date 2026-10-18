import Foundation
import Observation
import OSLog

@MainActor
@Observable
public final class TexturePackLibrary {
    private static let activePackKey = "texturePacks.activePackID"

    public private(set) var packs: [TexturePack]
    public private(set) var activePackID: TexturePack.ID

    public let defaultPack: TexturePack
    @ObservationIgnored private let bundledPackIDs: Set<TexturePack.ID>
    @ObservationIgnored private let installDirectory: URL
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let logger = Logger(subsystem: "MapSkin", category: "TexturePackLibrary")

    public init(defaults: UserDefaults, installDirectory: URL) throws {
        let bundled = try BundledTexturePacks.packNames().map {
            try TexturePack.load(from: BundledTexturePacks.packURL(named: $0))
        }
        guard let defaultPack = bundled.first(where: { $0.id == BundledTexturePacks.defaultPackName }) else {
            throw TexturePackError.manifestNotFound
        }
        self.defaultPack = defaultPack
        self.defaults = defaults
        self.installDirectory = installDirectory
        bundledPackIDs = Set(bundled.map(\.id))
        packs = bundled
        activePackID = defaultPack.id
        packs += installedPacks()
        activePackID = defaults.string(forKey: Self.activePackKey).flatMap { id in
            packs.contains { $0.id == id } ? id : nil
        } ?? defaultPack.id
    }

    public static func defaultInstallDirectory() throws -> URL {
        try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appending(path: "TexturePacks", directoryHint: .isDirectory)
    }

    public var activePack: TexturePack {
        packs.first { $0.id == activePackID } ?? defaultPack
    }

    public func isRemovable(_ pack: TexturePack) -> Bool {
        !bundledPackIDs.contains(pack.id)
    }

    public func select(_ pack: TexturePack) {
        guard packs.contains(where: { $0.id == pack.id }) else { return }
        activePackID = pack.id
        defaults.set(pack.id, forKey: Self.activePackKey)
    }

    @discardableResult
    public func importPack(from url: URL) async throws -> TexturePack {
        let importer = TexturePackImporter(defaultPack: defaultPack, installDirectory: installDirectory)
        let pack = try await Task.detached(priority: .userInitiated) {
            try importer.importPack(from: url)
        }.value
        packs.append(pack)
        select(pack)
        return pack
    }

    public func delete(_ pack: TexturePack) throws {
        guard isRemovable(pack) else { return }
        try FileManager.default.removeItem(at: pack.directoryURL)
        packs.removeAll { $0.id == pack.id }
        if activePackID == pack.id {
            select(defaultPack)
        }
    }

    private func installedPacks() -> [TexturePack] {
        let directories = (try? FileManager.default.contentsOfDirectory(
            at: installDirectory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )) ?? []
        return directories
            .compactMap { directory in
                do {
                    return try TexturePack.load(from: directory)
                } catch {
                    logger.error("Skipping unreadable texture pack at \(directory.lastPathComponent): \(error)")
                    return nil
                }
            }
            .sorted { $0.manifest.name.localizedStandardCompare($1.manifest.name) == .orderedAscending }
    }
}

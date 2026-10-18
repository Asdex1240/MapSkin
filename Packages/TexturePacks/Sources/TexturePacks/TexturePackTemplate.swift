import Foundation

public enum TexturePackTemplate {
    public static let fileExtension = "mapskin"
    private static let folderName = "MapSkinTemplate"

    public static func makeArchive(basedOn pack: TexturePack, in directory: URL) throws -> URL {
        let fileManager = FileManager.default
        let folder = directory.appending(path: folderName, directoryHint: .isDirectory)
        let archive = directory.appending(path: "\(folderName).\(fileExtension)")
        try? fileManager.removeItem(at: folder)
        try? fileManager.removeItem(at: archive)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try fileManager.copyItem(at: pack.directoryURL, to: folder)
        try templateManifest(basedOn: pack.manifest)
            .write(to: folder.appending(path: TexturePackManifest.fileName))
        try zip(folder, to: archive)
        try fileManager.removeItem(at: folder)
        return archive
    }

    private static func templateManifest(basedOn manifest: TexturePackManifest) throws -> Data {
        let template = TexturePackManifest(
            formatVersion: TexturePackLimits.supportedFormatVersion,
            name: "My Pack",
            author: "Your Name",
            description: "Replace the images in day/ and night/ with your own square PNG or JPEG textures.",
            license: "CC0 1.0",
            filtering: manifest.filtering,
            colors: manifest.colors
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(template)
    }

    private static func zip(_ folder: URL, to archive: URL) throws {
        var coordinationError: NSError?
        var copyError: Error?
        NSFileCoordinator().coordinate(readingItemAt: folder, options: [.forUploading], error: &coordinationError) {
            zippedURL in
            do {
                try FileManager.default.copyItem(at: zippedURL, to: archive)
            } catch {
                copyError = error
            }
        }
        if let error = coordinationError ?? copyError {
            throw error
        }
    }
}

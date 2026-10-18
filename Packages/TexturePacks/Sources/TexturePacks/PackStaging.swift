import Foundation

struct PackStaging {
    let directory: URL
    private let fileManager = FileManager.default

    init() throws {
        directory = FileManager.default.temporaryDirectory
            .appending(path: "TexturePackImport-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func remove() {
        try? fileManager.removeItem(at: directory)
    }

    func stage(archiveAt url: URL) throws {
        let archiveSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard archiveSize <= TexturePackLimits.maximumTotalBytes else { throw TexturePackImportError.tooLarge }
        let archive = try ZipArchive(data: Data(contentsOf: url))
        let files = try archive.entries
            .filter { !$0.isDirectory }
            .map { (entry: $0, components: try ArchivePath.components(of: $0.path)) }
            .filter { !ArchivePath.isIgnored($0.components) }
        try checkLimits(fileCount: files.count, totalBytes: files.reduce(0) { $0 + $1.entry.uncompressedSize })
        for file in files where ArchivePath.isAccepted(file.components) {
            try write(archive.contents(of: file.entry), to: file.components)
        }
    }

    func stage(directoryAt url: URL) throws {
        let files = try regularFiles(in: url)
            .map { (url: $0.url, size: $0.size, components: try relativeComponents(of: $0.url, in: url)) }
            .filter { !ArchivePath.isIgnored($0.components) }
        try checkLimits(fileCount: files.count, totalBytes: files.reduce(0) { $0 + $1.size })
        for file in files where ArchivePath.isAccepted(file.components) {
            try write(Data(contentsOf: file.url), to: file.components)
        }
    }

    func packRoot() throws -> URL {
        if fileManager.fileExists(atPath: directory.appending(path: TexturePackManifest.fileName).filePath) {
            return directory
        }
        let children = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )
        guard
            children.count == 1,
            let nested = children.first,
            fileManager.fileExists(atPath: nested.appending(path: TexturePackManifest.fileName).filePath)
        else { throw TexturePackImportError.manifestNotFound }
        return nested
    }

    private func checkLimits(fileCount: Int, totalBytes: Int) throws {
        guard fileCount <= TexturePackLimits.maximumFileCount else { throw TexturePackImportError.tooManyFiles }
        guard totalBytes <= TexturePackLimits.maximumTotalBytes else { throw TexturePackImportError.tooLarge }
    }

    private func write(_ data: Data, to components: [String]) throws {
        let destination = components.reduce(directory) { $0.appending(path: $1) }
        guard destination.standardizedFileURL.filePath.hasPrefix(directory.standardizedFileURL.filePath) else {
            throw TexturePackImportError.unsafePath
        }
        try fileManager.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: destination)
    }

    private func regularFiles(in directory: URL) throws -> [(url: URL, size: Int)] {
        let keys: [URLResourceKey] = [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey]
        guard let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: keys) else {
            throw TexturePackImportError.unreadableArchive
        }
        return try enumerator.compactMap { item in
            guard let url = item as? URL else { return nil }
            let values = try url.resourceValues(forKeys: Set(keys))
            guard values.isRegularFile == true, values.isSymbolicLink != true else { return nil }
            return (url, values.fileSize ?? 0)
        }
    }

    private func relativeComponents(of file: URL, in root: URL) throws -> [String] {
        let rootComponents = root.standardizedFileURL.resolvingSymlinksInPath().pathComponents
        let fileComponents = file.standardizedFileURL.resolvingSymlinksInPath().pathComponents
        guard fileComponents.starts(with: rootComponents) else { throw TexturePackImportError.unsafePath }
        return try ArchivePath.components(of: fileComponents.dropFirst(rootComponents.count).joined(separator: "/"))
    }
}

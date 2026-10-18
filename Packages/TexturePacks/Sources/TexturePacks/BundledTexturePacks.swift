import Foundation

public enum BundledTexturePacks {
    public static let defaultPackName = "placeholder"

    public static var rootURL: URL {
        Bundle.module.bundleURL.appending(path: "BundledPacks", directoryHint: .isDirectory)
    }

    public static func packURL(named name: String) -> URL {
        rootURL.appending(path: name, directoryHint: .isDirectory)
    }

    public static func packNames() throws -> [String] {
        try FileManager.default
            .contentsOfDirectory(at: rootURL, includingPropertiesForKeys: [.isDirectoryKey])
            .filter { try $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true }
            .map(\.lastPathComponent)
            .sorted()
    }
}

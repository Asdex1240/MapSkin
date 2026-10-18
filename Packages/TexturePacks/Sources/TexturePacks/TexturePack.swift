import Foundation

public struct TexturePack: Identifiable, Sendable {
    private static let supportedImageExtensions = ["png", "jpg", "jpeg"]
    public static let markerFileName = "marker.png"

    public let id: String
    public let manifest: TexturePackManifest
    public let directoryURL: URL

    public static func load(from directoryURL: URL) throws -> TexturePack {
        let manifestURL = directoryURL.appending(path: TexturePackManifest.fileName)
        guard FileManager.default.fileExists(atPath: manifestURL.filePath) else {
            throw TexturePackError.manifestNotFound
        }
        let manifest: TexturePackManifest
        do {
            manifest = try TexturePackManifest.decode(from: Data(contentsOf: manifestURL))
        } catch {
            throw TexturePackError.invalidManifest
        }
        return TexturePack(id: directoryURL.lastPathComponent, manifest: manifest, directoryURL: directoryURL)
    }

    public var markerURL: URL? {
        let url = directoryURL.appending(path: Self.markerFileName)
        return FileManager.default.fileExists(atPath: url.filePath) ? url : nil
    }

    public func textureURL(for kind: TextureKind, appearance: MapAppearance) -> URL? {
        let variantURL = directoryURL.appending(path: appearance.rawValue, directoryHint: .isDirectory)
        return Self.supportedImageExtensions
            .map { variantURL.appending(path: "\(kind.rawValue).\($0)") }
            .first { FileManager.default.fileExists(atPath: $0.filePath) }
    }
}

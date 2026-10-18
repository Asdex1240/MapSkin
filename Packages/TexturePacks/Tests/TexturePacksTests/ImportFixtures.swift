import Foundation
import ImageIO
import UniformTypeIdentifiers
@testable import TexturePacks

struct ImportFixtures {
    let root: URL

    init() throws {
        root = FileManager.default.temporaryDirectory.appending(path: "ImportTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    }

    var installDirectory: URL {
        root.appending(path: "Application Support/TexturePacks", directoryHint: .isDirectory)
    }

    func remove() {
        try? FileManager.default.removeItem(at: root)
    }

    func defaultPack() throws -> TexturePack {
        try TexturePack.load(from: BundledTexturePacks.packURL(named: BundledTexturePacks.defaultPackName))
    }

    func importer() throws -> TexturePackImporter {
        TexturePackImporter(defaultPack: try defaultPack(), installDirectory: installDirectory)
    }

    func file(named name: String) -> URL {
        root.appending(path: name)
    }

    static func manifestData(formatVersion: Int = 1, filtering: String = "smooth") -> Data {
        let json = #"{ "formatVersion": \#(formatVersion), "name": "Imported", "author": "Tests", "#
            + #""filtering": "\#(filtering)" }"#
        return Data(json.utf8)
    }

    static func png(size: Int, height: Int? = nil) throws -> Data {
        let image = try TestImages.make(
            rows: Array(
                repeating: Array(repeating: RGBAPixel(red: 40, green: 160, blue: 80), count: size),
                count: height ?? size
            )
        )
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else {
            throw TexturePackImportError.invalidImage("fixture")
        }
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
        return data as Data
    }

    static func validArchive(prefix: String = "", kinds: [TextureKind] = [.grass, .water]) throws -> TestZipBuilder {
        var builder = TestZipBuilder()
        builder.add("\(prefix)pack.json", data: manifestData())
        for kind in kinds {
            builder.add("\(prefix)day/\(kind.rawValue).png", data: try png(size: 16))
        }
        return builder
    }
}

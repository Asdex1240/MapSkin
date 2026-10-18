import Foundation

public struct TexturePackManifest: Codable, Equatable, Sendable {
    public static let fileName = "pack.json"

    public let formatVersion: Int
    public let name: String
    public let author: String
    public let description: String?
    public let license: String?
    public let filtering: TextureFiltering
    public let colors: ThemeColors?

    public init(
        formatVersion: Int,
        name: String,
        author: String,
        description: String? = nil,
        license: String? = nil,
        filtering: TextureFiltering,
        colors: ThemeColors? = nil
    ) {
        self.formatVersion = formatVersion
        self.name = name
        self.author = author
        self.description = description
        self.license = license
        self.filtering = filtering
        self.colors = colors
    }

    public static func decode(from data: Data) throws -> TexturePackManifest {
        try JSONDecoder().decode(TexturePackManifest.self, from: data)
    }
}

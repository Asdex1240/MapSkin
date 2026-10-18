import TexturePacks

public struct MapSkin: Identifiable, Sendable {
    public let id: String
    public let styleJSON: String
    public let images: [String: TextureImage]

    public init(id: String, styleJSON: String, images: [String: TextureImage]) {
        self.id = id
        self.styleJSON = styleJSON
        self.images = images
    }
}

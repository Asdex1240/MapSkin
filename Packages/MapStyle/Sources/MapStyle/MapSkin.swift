import TexturePacks

public struct MapSkin: Identifiable, Sendable {
    public let id: String
    public let styleJSON: String
    public let images: [String: TextureImage]
    public let palette: MapPalette

    public init(id: String, styleJSON: String, images: [String: TextureImage], palette: MapPalette) {
        self.id = id
        self.styleJSON = styleJSON
        self.images = images
        self.palette = palette
    }
}

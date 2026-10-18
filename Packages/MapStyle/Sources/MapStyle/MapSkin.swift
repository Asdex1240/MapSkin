import TexturePacks

public struct MapSkin: Identifiable, Sendable {
    public let id: String
    public let styleJSON: String
    public let images: [String: TextureImage]
    public let palette: MapPalette
    public let marker: TextureImage?
    public let filtering: TextureFiltering

    public init(
        id: String,
        styleJSON: String,
        images: [String: TextureImage],
        palette: MapPalette,
        marker: TextureImage? = nil,
        filtering: TextureFiltering = .smooth
    ) {
        self.id = id
        self.styleJSON = styleJSON
        self.images = images
        self.palette = palette
        self.marker = marker
        self.filtering = filtering
    }
}

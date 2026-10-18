import TexturePacks

public struct MapSkinFactory: Sendable {
    private let styleBuilder: MapStyleBuilder

    public init(styleBuilder: MapStyleBuilder) {
        self.styleBuilder = styleBuilder
    }

    public func makeSkin(pack: TexturePack, appearance: MapAppearance, screenScale: Double) async throws -> MapSkin {
        let palette = MapPalette.resolved(with: pack.manifest.colors?.overrides(for: appearance), for: appearance)
        let textures = try TextureSetLoader(screenScale: screenScale).loadTextures(of: pack, for: appearance)
        let images = Dictionary(uniqueKeysWithValues: textures.map { ($0.key.styleImageName, $0.value) })
        return MapSkin(
            id: "\(pack.id)-\(appearance.rawValue)-\(screenScale)",
            styleJSON: try styleBuilder.styleJSON(palette: palette),
            images: images,
            palette: palette
        )
    }
}

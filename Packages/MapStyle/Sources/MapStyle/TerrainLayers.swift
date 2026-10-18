import TexturePacks

enum TerrainLayers {
    private static let faintOpacity = 0.35

    static func make(palette: MapPalette, source: String) -> [StyleLayer] {
        [
            background(palette),
            texturedFill(id: "landuse-urban", source: source, sourceLayer: "landuse",
                         classes: ["residential", "commercial", "retail"], texture: .urban, opacity: faintOpacity),
            texturedFill(id: "landuse-industrial", source: source, sourceLayer: "landuse",
                         classes: ["industrial"], texture: .industrial, opacity: faintOpacity),
            texturedFill(id: "landcover-grass", source: source, sourceLayer: "landcover",
                         classes: ["grass"], texture: .grass),
            texturedFill(id: "park", source: source, sourceLayer: "park", classes: nil, texture: .grass),
            texturedFill(id: "landcover-wood", source: source, sourceLayer: "landcover",
                         classes: ["wood"], texture: .forest),
            texturedFill(id: "landcover-sand", source: source, sourceLayer: "landcover",
                         classes: ["sand"], texture: .sand),
            texturedFill(id: "landcover-rock", source: source, sourceLayer: "landcover",
                         classes: ["rock"], texture: .rock),
            texturedFill(id: "landcover-ice", source: source, sourceLayer: "landcover",
                         classes: ["ice"], texture: .snow),
            texturedFill(id: "water", source: source, sourceLayer: "water", classes: nil, texture: .water),
            waterway(palette, source: source)
        ]
    }

    private static func background(_ palette: MapPalette) -> StyleLayer {
        [
            "id": "background",
            "type": "background",
            "paint": ["background-color": palette.background.hexString]
        ]
    }

    private static func texturedFill(
        id: String,
        source: String,
        sourceLayer: String,
        classes: [String]?,
        texture: TextureKind,
        opacity: Double = 1
    ) -> StyleLayer {
        var layer: StyleLayer = [
            "id": id,
            "type": "fill",
            "source": source,
            "source-layer": sourceLayer,
            "paint": [
                "fill-pattern": texture.styleImageName,
                "fill-opacity": opacity
            ]
        ]
        if let classes {
            layer["filter"] = StyleExpression.classIn(classes)
        }
        return layer
    }

    private static func waterway(_ palette: MapPalette, source: String) -> StyleLayer {
        [
            "id": "waterway",
            "type": "line",
            "source": source,
            "source-layer": "waterway",
            "layout": ["line-cap": "round", "line-join": "round"],
            "paint": [
                "line-color": palette.waterLine.hexString,
                "line-width": StyleExpression.zoomInterpolated([(8, 0.5), (14, 2), (18, 6)])
            ]
        ]
    }
}

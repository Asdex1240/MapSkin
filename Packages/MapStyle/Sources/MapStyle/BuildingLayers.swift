import TexturePacks

enum BuildingLayers {
    static let extrusionMinZoom = 16.0
    private static let minZoom = 13.0

    static func make(palette: MapPalette, source: String) -> [StyleLayer] {
        [texturedFootprint(source: source), outline(palette, source: source), extrusion(palette, source: source)]
    }

    private static func texturedFootprint(source: String) -> StyleLayer {
        [
            "id": "building",
            "type": "fill",
            "source": source,
            "source-layer": "building",
            "minzoom": minZoom,
            "maxzoom": extrusionMinZoom,
            "paint": ["fill-pattern": TextureKind.building.styleImageName]
        ]
    }

    private static func outline(_ palette: MapPalette, source: String) -> StyleLayer {
        [
            "id": "building-outline",
            "type": "line",
            "source": source,
            "source-layer": "building",
            "minzoom": minZoom,
            "maxzoom": extrusionMinZoom,
            "paint": [
                "line-color": palette.buildingOutline.hexString,
                "line-width": 1
            ]
        ]
    }

    private static func extrusion(_ palette: MapPalette, source: String) -> StyleLayer {
        [
            "id": "building-extrusion",
            "type": "fill-extrusion",
            "source": source,
            "source-layer": "building",
            "minzoom": extrusionMinZoom,
            "paint": [
                "fill-extrusion-color": palette.buildingExtrusion.hexString,
                "fill-extrusion-height": ["coalesce", ["get", "render_height"], 0],
                "fill-extrusion-base": ["coalesce", ["get", "render_min_height"], 0],
                "fill-extrusion-opacity": 0.9
            ]
        ]
    }
}

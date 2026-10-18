enum RoadLayers {
    private struct RoadClass {
        let id: String
        let classes: [String]
        let minZoom: Double
        let fillWidth: [(zoom: Double, value: Double)]
        let casingWidth: [(zoom: Double, value: Double)]
    }

    private static let minor = RoadClass(
        id: "road-minor",
        classes: ["minor", "service"],
        minZoom: 12,
        fillWidth: [(12, 0.5), (14, 2.5), (18, 12)],
        casingWidth: [(12, 1), (14, 4), (18, 15)]
    )

    private static let secondary = RoadClass(
        id: "road-secondary",
        classes: ["secondary", "tertiary"],
        minZoom: 8,
        fillWidth: [(8, 0.5), (12, 2), (14, 4.5), (18, 16)],
        casingWidth: [(8, 1), (12, 3.4), (14, 6.5), (18, 20)]
    )

    private static let major = RoadClass(
        id: "road-major",
        classes: ["motorway", "trunk", "primary"],
        minZoom: 5,
        fillWidth: [(5, 1), (10, 2.5), (14, 7), (18, 22)],
        casingWidth: [(5, 1.6), (10, 4), (14, 10), (18, 28)]
    )

    static func make(palette: MapPalette, source: String) -> [StyleLayer] {
        [
            path(palette, source: source),
            casing(minor, color: palette.roadCasing, source: source),
            casing(secondary, color: palette.roadCasing, source: source),
            casing(major, color: palette.majorRoadCasing, source: source),
            fill(minor, color: palette.minorRoad, source: source),
            fill(secondary, color: palette.road, source: source),
            fill(major, color: palette.road, source: source)
        ]
    }

    private static func casing(_ road: RoadClass, color: RGBColor, source: String) -> StyleLayer {
        line(id: "\(road.id)-casing", road: road, color: color, width: road.casingWidth, source: source)
    }

    private static func fill(_ road: RoadClass, color: RGBColor, source: String) -> StyleLayer {
        line(id: road.id, road: road, color: color, width: road.fillWidth, source: source)
    }

    private static func line(
        id: String,
        road: RoadClass,
        color: RGBColor,
        width: [(zoom: Double, value: Double)],
        source: String
    ) -> StyleLayer {
        [
            "id": id,
            "type": "line",
            "source": source,
            "source-layer": "transportation",
            "minzoom": road.minZoom,
            "filter": StyleExpression.classIn(road.classes),
            "layout": ["line-cap": "round", "line-join": "round"],
            "paint": [
                "line-color": color.hexString,
                "line-width": StyleExpression.zoomInterpolated(width)
            ]
        ]
    }

    private static func path(_ palette: MapPalette, source: String) -> StyleLayer {
        [
            "id": "road-path",
            "type": "line",
            "source": source,
            "source-layer": "transportation",
            "minzoom": 14.0,
            "filter": StyleExpression.classIn(["path", "track"]),
            "layout": ["line-join": "round"],
            "paint": [
                "line-color": palette.path.hexString,
                "line-dasharray": [2, 1.5],
                "line-width": StyleExpression.zoomInterpolated([(14, 1), (18, 2.5)])
            ]
        ]
    }
}

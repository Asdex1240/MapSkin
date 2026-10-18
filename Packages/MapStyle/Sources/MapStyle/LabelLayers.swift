enum LabelLayers {
    static let regularFont = "Noto Sans Regular"
    static let boldFont = "Noto Sans Bold"
    private static let haloWidth = 1.5

    static func make(palette: MapPalette, language: String, source: String) -> [StyleLayer] {
        [
            waterNames(palette, language: language, source: source),
            roadNames(palette, language: language, source: source),
            placeNames(palette, language: language, source: source)
        ]
    }

    private static func waterNames(_ palette: MapPalette, language: String, source: String) -> StyleLayer {
        [
            "id": "label-water",
            "type": "symbol",
            "source": source,
            "source-layer": "water_name",
            "layout": [
                "text-field": StyleExpression.localizedName(language: language),
                "text-font": [regularFont],
                "text-size": StyleExpression.zoomInterpolated([(6, 12), (14, 15)], base: 1)
            ],
            "paint": textPaint(color: palette.waterLine.darkened(by: 0.35), halo: palette.labelHalo)
        ]
    }

    private static func roadNames(_ palette: MapPalette, language: String, source: String) -> StyleLayer {
        [
            "id": "label-road",
            "type": "symbol",
            "source": source,
            "source-layer": "transportation_name",
            "minzoom": 13.0,
            "layout": [
                "symbol-placement": "line",
                "text-field": StyleExpression.localizedName(language: language),
                "text-font": [regularFont],
                "text-size": StyleExpression.zoomInterpolated([(13, 12), (18, 16)], base: 1)
            ],
            "paint": textPaint(color: palette.label, halo: palette.labelHalo)
        ]
    }

    private static func placeNames(_ palette: MapPalette, language: String, source: String) -> StyleLayer {
        [
            "id": "label-place",
            "type": "symbol",
            "source": source,
            "source-layer": "place",
            "filter": StyleExpression.classIn(["city", "town", "village", "suburb", "neighbourhood"]),
            "layout": [
                "text-field": StyleExpression.localizedName(language: language),
                "text-font": ["match", ["get", "class"], "city", ["literal", [boldFont]], ["literal", [regularFont]]],
                "text-size": [
                    "interpolate", ["linear"], ["zoom"],
                    4, ["match", ["get", "class"], "city", 13, 12],
                    12, ["match", ["get", "class"], "city", 22, "town", 18, 15]
                ] as [Any],
                "symbol-sort-key": ["coalesce", ["get", "rank"], 99]
            ],
            "paint": textPaint(color: palette.label, halo: palette.labelHalo)
        ]
    }

    private static func textPaint(color: RGBColor, halo: RGBColor) -> [String: Any] {
        [
            "text-color": color.hexString,
            "text-halo-color": halo.hexString,
            "text-halo-width": haloWidth
        ]
    }
}

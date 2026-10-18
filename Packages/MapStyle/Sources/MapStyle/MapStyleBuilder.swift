import Foundation

public struct MapStyleBuilder: Sendable {
    static let sourceID = "openmaptiles"

    public let tilesURL: URL
    public let glyphsURL: String
    public let labelLanguage: String

    public init(tilesURL: URL, glyphsURL: String, labelLanguage: String) {
        self.tilesURL = tilesURL
        self.glyphsURL = glyphsURL
        self.labelLanguage = labelLanguage
    }

    public func styleJSON(palette: MapPalette) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: style(palette: palette), options: [.sortedKeys])
        return String(decoding: data, as: UTF8.self)
    }

    private func style(palette: MapPalette) -> [String: Any] {
        [
            "version": 8,
            "name": "MapSkin",
            "glyphs": glyphsURL,
            "sources": [
                Self.sourceID: ["type": "vector", "url": tilesURL.absoluteString]
            ],
            "layers": layers(palette: palette)
        ]
    }

    private func layers(palette: MapPalette) -> [StyleLayer] {
        TerrainLayers.make(palette: palette, source: Self.sourceID)
            + BuildingLayers.make(palette: palette, source: Self.sourceID)
            + RoadLayers.make(palette: palette, source: Self.sourceID)
            + LabelLayers.make(palette: palette, language: labelLanguage, source: Self.sourceID)
    }
}

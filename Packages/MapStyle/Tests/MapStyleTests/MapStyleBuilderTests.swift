import Foundation
import MapStyle
import Testing
import TexturePacks

struct MapStyleBuilderTests {
    private let builder = MapStyleBuilder(
        tilesURL: URL(string: "https://tiles.example.com/planet")!,
        glyphsURL: "https://tiles.example.com/fonts/{fontstack}/{range}.pbf",
        labelLanguage: "es"
    )

    @Test func pointsToConfiguredTilesAndGlyphs() throws {
        let style = try decodedStyle()

        #expect(style["glyphs"] as? String == "https://tiles.example.com/fonts/{fontstack}/{range}.pbf")
        let sources = try #require(style["sources"] as? [String: [String: String]])
        #expect(sources.values.first?["url"] == "https://tiles.example.com/planet")
    }

    @Test func usesEveryTextureOfThePack() throws {
        let patterns = try layers().compactMap { paint(of: $0)["fill-pattern"] as? String }

        #expect(Set(patterns) == Set(TextureKind.allCases.map(\.styleImageName)))
    }

    @Test func neverTexturesRoads() throws {
        let roadLayers = try layers().filter { $0["source-layer"] as? String == "transportation" }

        #expect(!roadLayers.isEmpty)
        for layer in roadLayers {
            #expect(layer["type"] as? String == "line")
            #expect(paint(of: layer)["line-pattern"] == nil)
            #expect(paint(of: layer)["line-color"] is String)
        }
    }

    @Test func drawsLabelsAboveEverythingElse() throws {
        let types = try layers().compactMap { $0["type"] as? String }

        let firstSymbol = try #require(types.firstIndex(of: "symbol"))
        #expect(types[firstSymbol...].allSatisfy { $0 == "symbol" })
    }

    @Test func extrudesBuildingsOnlyFromZoomSixteen() throws {
        let buildingLayers = try layers().filter { $0["source-layer"] as? String == "building" }

        let extrusion = try #require(buildingLayers.first { $0["type"] as? String == "fill-extrusion" })
        #expect(extrusion["minzoom"] as? Double == 16)
        let footprint = try #require(buildingLayers.first { paint(of: $0)["fill-pattern"] != nil })
        #expect(footprint["maxzoom"] as? Double == 16)
    }

    @Test func labelsPreferConfiguredLanguage() throws {
        let labels = try layers().filter { $0["type"] as? String == "symbol" }

        for label in labels {
            let layout = try #require(label["layout"] as? [String: Any])
            let textField = try #require(layout["text-field"] as? [Any])
            let preferred = try #require(textField[1] as? [String])
            #expect(preferred == ["get", "name:es"])
        }
    }

    @Test func paintsBackgroundWithPaletteColor() throws {
        let palette = MapPalette.standard(for: .night)

        let background = try #require(try layers(palette: palette).first)

        #expect(background["type"] as? String == "background")
        #expect(paint(of: background)["background-color"] as? String == palette.background.hexString)
    }

    @Test func layerIdentifiersAreUnique() throws {
        let identifiers = try layers().compactMap { $0["id"] as? String }

        #expect(Set(identifiers).count == identifiers.count)
    }

    private func decodedStyle(palette: MapPalette = .standard(for: .day)) throws -> [String: Any] {
        let json = try builder.styleJSON(palette: palette)
        return try #require(try JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any])
    }

    private func layers(palette: MapPalette = .standard(for: .day)) throws -> [[String: Any]] {
        try #require(try decodedStyle(palette: palette)["layers"] as? [[String: Any]])
    }

    private func paint(of layer: [String: Any]) -> [String: Any] {
        layer["paint"] as? [String: Any] ?? [:]
    }
}

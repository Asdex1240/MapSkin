import MapStyle
import Testing
import TexturePacks

struct MapPaletteTests {
    @Test(arguments: MapAppearance.allCases)
    func standardPaletteKeepsRouteAndRoadsLegible(appearance: MapAppearance) {
        let palette = MapPalette.standard(for: appearance)

        #expect(palette.route.contrastRatio(with: palette.background) >= MapPalette.minimumRouteContrast)
        let roadContrast = max(
            palette.road.contrastRatio(with: palette.background),
            palette.roadCasing.contrastRatio(with: palette.background)
        )
        #expect(roadContrast >= MapPalette.minimumRoadContrast)
    }

    @Test func usesStandardPaletteWithoutOverrides() {
        #expect(MapPalette.resolved(with: nil, for: .night) == MapPalette.standard(for: .night))
    }

    @Test func appliesLegibleOverrides() {
        let overrides = PaletteOverrides(background: "#FFFFFF", label: "#101010", route: "#D32F2F")

        let palette = MapPalette.resolved(with: overrides, for: .day)

        #expect(palette.background.hexString == "#FFFFFF")
        #expect(palette.label.hexString == "#101010")
        #expect(palette.route.hexString == "#D32F2F")
    }

    @Test func ignoresRouteWithoutEnoughContrast() {
        let overrides = PaletteOverrides(background: "#FFFFFF", route: "#F5F5F5")

        let palette = MapPalette.resolved(with: overrides, for: .day)

        #expect(palette.route == MapPalette.standard(for: .day).route)
    }

    @Test func ignoresRoadsThatBlendIntoBackground() {
        let overrides = PaletteOverrides(background: "#202020", road: "#222222", roadCasing: "#1E1E1E")

        let palette = MapPalette.resolved(with: overrides, for: .night)

        let standard = MapPalette.standard(for: .night)
        #expect(palette.road == standard.road)
        #expect(palette.roadCasing == standard.roadCasing)
    }

    @Test func ignoresInvalidHexValues() {
        let overrides = PaletteOverrides(background: "not-a-color", route: "#12")

        let palette = MapPalette.resolved(with: overrides, for: .day)

        #expect(palette == MapPalette.standard(for: .day))
    }
}

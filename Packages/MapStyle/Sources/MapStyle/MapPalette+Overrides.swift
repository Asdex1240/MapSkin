import TexturePacks

extension MapPalette {
    public static let minimumRouteContrast = 3.0
    public static let minimumRoadContrast = 1.4

    public static func resolved(with overrides: PaletteOverrides?, for appearance: MapAppearance) -> MapPalette {
        let standard = MapPalette.standard(for: appearance)
        guard let overrides else { return standard }

        var palette = standard
        palette.background = color(from: overrides.background) ?? standard.background
        palette.label = color(from: overrides.label) ?? standard.label
        palette.route = legibleRoute(color(from: overrides.route), on: palette.background) ?? standard.route
        let roads = legibleRoads(
            road: color(from: overrides.road) ?? standard.road,
            casing: color(from: overrides.roadCasing) ?? standard.roadCasing,
            on: palette.background
        )
        palette.road = roads?.road ?? standard.road
        palette.roadCasing = roads?.casing ?? standard.roadCasing
        return palette
    }

    private static func color(from hex: String?) -> RGBColor? {
        hex.flatMap(RGBColor.init(hex:))
    }

    private static func legibleRoute(_ route: RGBColor?, on background: RGBColor) -> RGBColor? {
        guard let route, route.contrastRatio(with: background) >= minimumRouteContrast else { return nil }
        return route
    }

    private static func legibleRoads(
        road: RGBColor,
        casing: RGBColor,
        on background: RGBColor
    ) -> (road: RGBColor, casing: RGBColor)? {
        let bestContrast = max(road.contrastRatio(with: background), casing.contrastRatio(with: background))
        return bestContrast >= minimumRoadContrast ? (road, casing) : nil
    }
}

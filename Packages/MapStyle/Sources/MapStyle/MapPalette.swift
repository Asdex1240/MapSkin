import TexturePacks

public struct MapPalette: Equatable, Sendable {
    public var background: RGBColor
    public var road: RGBColor
    public var roadCasing: RGBColor
    public var label: RGBColor
    public var route: RGBColor
    public var waterLine: RGBColor

    public init(
        background: RGBColor,
        road: RGBColor,
        roadCasing: RGBColor,
        label: RGBColor,
        route: RGBColor,
        waterLine: RGBColor
    ) {
        self.background = background
        self.road = road
        self.roadCasing = roadCasing
        self.label = label
        self.route = route
        self.waterLine = waterLine
    }

    public var labelHalo: RGBColor { background }
    public var majorRoadCasing: RGBColor { roadCasing.darkened(by: 0.25) }
    public var minorRoad: RGBColor { road.mixed(with: background, amount: 0.2) }
    public var path: RGBColor { label.mixed(with: background, amount: 0.45) }
    public var routeCasing: RGBColor { route.darkened(by: 0.35) }
    public var buildingOutline: RGBColor { label.mixed(with: background, amount: 0.6) }
    public var buildingExtrusion: RGBColor { roadCasing.mixed(with: background, amount: 0.3) }

    public static func standard(for appearance: MapAppearance) -> MapPalette {
        switch appearance {
        case .day: .standardDay
        case .night: .standardNight
        }
    }

    private static let standardDay = MapPalette(
        background: RGBColor(red: 0.929, green: 0.918, blue: 0.886),
        road: .white,
        roadCasing: RGBColor(red: 0.784, green: 0.761, blue: 0.706),
        label: RGBColor(red: 0.2, green: 0.2, blue: 0.2),
        route: RGBColor(red: 0.102, green: 0.451, blue: 0.91),
        waterLine: RGBColor(red: 0.498, green: 0.698, blue: 0.898)
    )

    private static let standardNight = MapPalette(
        background: RGBColor(red: 0.118, green: 0.133, blue: 0.157),
        road: RGBColor(red: 0.353, green: 0.384, blue: 0.439),
        roadCasing: RGBColor(red: 0.173, green: 0.196, blue: 0.231),
        label: RGBColor(red: 0.902, green: 0.902, blue: 0.902),
        route: RGBColor(red: 0.31, green: 0.765, blue: 0.969),
        waterLine: RGBColor(red: 0.184, green: 0.361, blue: 0.502)
    )
}

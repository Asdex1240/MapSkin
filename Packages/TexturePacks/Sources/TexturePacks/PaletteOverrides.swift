public struct PaletteOverrides: Codable, Equatable, Sendable {
    public let background: String?
    public let road: String?
    public let roadCasing: String?
    public let label: String?
    public let route: String?

    public init(
        background: String? = nil,
        road: String? = nil,
        roadCasing: String? = nil,
        label: String? = nil,
        route: String? = nil
    ) {
        self.background = background
        self.road = road
        self.roadCasing = roadCasing
        self.label = label
        self.route = route
    }
}

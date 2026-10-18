public struct ThemeColors: Codable, Equatable, Sendable {
    public let day: PaletteOverrides?
    public let night: PaletteOverrides?

    public init(day: PaletteOverrides? = nil, night: PaletteOverrides? = nil) {
        self.day = day
        self.night = night
    }

    public func overrides(for appearance: MapAppearance) -> PaletteOverrides? {
        switch appearance {
        case .day: day
        case .night: night
        }
    }
}

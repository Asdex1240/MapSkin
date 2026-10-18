public struct ThemeColors: Codable, Equatable, Sendable {
    public let day: PaletteOverrides?
    public let night: PaletteOverrides?

    public init(day: PaletteOverrides? = nil, night: PaletteOverrides? = nil) {
        self.day = day
        self.night = night
    }
}

import NavigationCore

public struct Place: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let name: String
    public let address: String?
    public let coordinate: GeoCoordinate

    public init(name: String, address: String?, coordinate: GeoCoordinate) {
        self.id = Self.identifier(name: name, coordinate: coordinate)
        self.name = name
        self.address = address
        self.coordinate = coordinate
    }

    private static func identifier(name: String, coordinate: GeoCoordinate) -> String {
        let latitude = (coordinate.latitude * 100_000).rounded() / 100_000
        let longitude = (coordinate.longitude * 100_000).rounded() / 100_000
        return "\(name)|\(latitude)|\(longitude)"
    }
}

public struct RouteRequest: Equatable, Sendable {
    public let origin: GeoCoordinate
    public let destination: GeoCoordinate
    public let avoidsTolls: Bool

    public init(origin: GeoCoordinate, destination: GeoCoordinate, avoidsTolls: Bool = false) {
        self.origin = origin
        self.destination = destination
        self.avoidsTolls = avoidsTolls
    }

    public func departing(from origin: GeoCoordinate) -> RouteRequest {
        RouteRequest(origin: origin, destination: destination, avoidsTolls: avoidsTolls)
    }
}

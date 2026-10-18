import Foundation

public struct Route: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let polyline: [GeoCoordinate]
    public let maneuvers: [Maneuver]
    public let distance: Measurement<UnitLength>
    public let expectedTravelTime: Duration

    public init(
        id: String,
        name: String,
        polyline: [GeoCoordinate],
        maneuvers: [Maneuver],
        distance: Measurement<UnitLength>,
        expectedTravelTime: Duration
    ) {
        self.id = id
        self.name = name
        self.polyline = polyline
        self.maneuvers = maneuvers
        self.distance = distance
        self.expectedTravelTime = expectedTravelTime
    }
}

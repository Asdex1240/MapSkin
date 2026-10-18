import Foundation

public struct LocationSample: Equatable, Sendable {
    public let coordinate: GeoCoordinate
    public let course: Double?
    public let speed: Double?
    public let horizontalAccuracy: Double
    public let timestamp: Date

    public init(
        coordinate: GeoCoordinate,
        course: Double? = nil,
        speed: Double? = nil,
        horizontalAccuracy: Double = 5,
        timestamp: Date
    ) {
        self.coordinate = coordinate
        self.course = course
        self.speed = speed
        self.horizontalAccuracy = horizontalAccuracy
        self.timestamp = timestamp
    }
}

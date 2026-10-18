import Foundation

public struct GeoCoordinate: Hashable, Codable, Sendable {
    static let earthRadius = 6_371_000.0

    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public func distance(to other: GeoCoordinate) -> Double {
        let deltaLatitude = (other.latitude - latitude).radians
        let deltaLongitude = (other.longitude - longitude).radians
        let haversine = sin(deltaLatitude / 2) * sin(deltaLatitude / 2)
            + cos(latitude.radians) * cos(other.latitude.radians) * sin(deltaLongitude / 2) * sin(deltaLongitude / 2)
        return 2 * Self.earthRadius * atan2(sqrt(haversine), sqrt(1 - haversine))
    }

    public func bearing(to other: GeoCoordinate) -> Double {
        let deltaLongitude = (other.longitude - longitude).radians
        let y = sin(deltaLongitude) * cos(other.latitude.radians)
        let x = cos(latitude.radians) * sin(other.latitude.radians)
            - sin(latitude.radians) * cos(other.latitude.radians) * cos(deltaLongitude)
        return (atan2(y, x).degrees + 360).truncatingRemainder(dividingBy: 360)
    }
}

extension Double {
    var radians: Double { self * .pi / 180 }
    var degrees: Double { self * 180 / .pi }
}

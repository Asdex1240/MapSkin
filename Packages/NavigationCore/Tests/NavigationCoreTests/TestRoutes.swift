import Foundation
import NavigationCore

enum TestRoutes {
    static let origin = GeoCoordinate(latitude: 25.67, longitude: -100.31)
    static let startDate = Date(timeIntervalSince1970: 1_800_000_000)

    static func point(north: Double, east: Double = 0) -> GeoCoordinate {
        let metersPerDegreeLatitude = GeoCoordinate.metersPerDegreeLatitude
        let metersPerDegreeLongitude = metersPerDegreeLatitude * cos(origin.latitude * .pi / 180)
        return GeoCoordinate(
            latitude: origin.latitude + north / metersPerDegreeLatitude,
            longitude: origin.longitude + east / metersPerDegreeLongitude
        )
    }

    static func sample(north: Double, east: Double = 0, after seconds: TimeInterval = 0) -> LocationSample {
        LocationSample(coordinate: point(north: north, east: east), timestamp: startDate.addingTimeInterval(seconds))
    }

    static let northbound = Route(
        id: "northbound",
        name: "Northbound",
        polyline: stride(from: 0.0, through: 1000, by: 250).map { point(north: $0) },
        maneuvers: [
            Maneuver(id: 0, kind: .depart, instruction: "Head north", coordinate: point(north: 0)),
            Maneuver(id: 1, kind: .turnRight, instruction: "Turn right", coordinate: point(north: 500)),
            Maneuver(id: 2, kind: .arrive, instruction: "Arrive", coordinate: point(north: 1000))
        ],
        distance: Measurement(value: 1000, unit: .meters),
        expectedTravelTime: .seconds(100)
    )

    static let request = RouteRequest(origin: point(north: 0), destination: point(north: 1000))
}

extension GeoCoordinate {
    static let metersPerDegreeLatitude = 6_371_000.0 * .pi / 180
}

import MapKit
import NavigationCore

enum RouteMapper {
    static func route(from route: MKRoute, index: Int) -> Route {
        Route(
            id: "\(index)-\(route.name)-\(Int(route.distance))",
            name: route.name,
            polyline: coordinates(of: route.polyline),
            maneuvers: maneuvers(from: route.steps),
            distance: Measurement(value: route.distance, unit: .meters),
            expectedTravelTime: .seconds(route.expectedTravelTime)
        )
    }

    private static func maneuvers(from steps: [MKRoute.Step]) -> [Maneuver] {
        let paths = steps.map { coordinates(of: $0.polyline) }
        return steps.indices.compactMap { index in
            let instruction = steps[index].instructions
            guard !instruction.isEmpty, let coordinate = paths[index].first else { return nil }
            return Maneuver(
                id: index,
                kind: kind(ofStepAt: index, in: paths),
                instruction: instruction,
                coordinate: coordinate
            )
        }
    }

    private static func kind(ofStepAt index: Int, in paths: [[GeoCoordinate]]) -> ManeuverKind {
        if index == 0 { return .depart }
        if index == paths.count - 1 { return .arrive }
        return ManeuverKind(arrivingAlong: paths[index - 1], leavingAlong: paths[index])
    }

    private static func coordinates(of polyline: MKPolyline) -> [GeoCoordinate] {
        let count = polyline.pointCount
        var coordinates = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: count)
        polyline.getCoordinates(&coordinates, range: NSRange(location: 0, length: count))
        return coordinates.map { GeoCoordinate(latitude: $0.latitude, longitude: $0.longitude) }
    }
}

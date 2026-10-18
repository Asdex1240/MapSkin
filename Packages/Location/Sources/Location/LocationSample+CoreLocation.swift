import CoreLocation
import NavigationCore

extension LocationSample {
    init(_ location: CLLocation) {
        self.init(
            coordinate: GeoCoordinate(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            ),
            course: location.course >= 0 ? location.course : nil,
            speed: location.speed >= 0 ? location.speed : nil,
            horizontalAccuracy: location.horizontalAccuracy,
            timestamp: location.timestamp
        )
    }
}

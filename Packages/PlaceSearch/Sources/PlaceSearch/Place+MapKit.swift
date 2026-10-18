import MapKit
import NavigationCore

extension Place {
    init?(_ mapItem: MKMapItem) {
        let placemark = mapItem.placemark
        guard let name = mapItem.name ?? placemark.name else { return nil }
        self.init(
            name: name,
            address: Self.address(of: placemark, excluding: name),
            coordinate: GeoCoordinate(
                latitude: placemark.coordinate.latitude,
                longitude: placemark.coordinate.longitude
            )
        )
    }

    private static func address(of placemark: MKPlacemark, excluding name: String) -> String? {
        let street = [placemark.thoroughfare, placemark.subThoroughfare].compactMap { $0 }.joined(separator: " ")
        let parts = [street, placemark.subLocality, placemark.locality]
            .compactMap { $0 }
            .filter { !$0.isEmpty && $0 != name }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}

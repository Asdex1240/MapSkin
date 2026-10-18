import Foundation
import NavigationCore
import PlaceSearch

struct TestDefaults {
    let suiteName = "PlaceSearchTests-\(UUID().uuidString)"

    var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    func clear() {
        defaults.removePersistentDomain(forName: suiteName)
    }
}

func makePlace(_ name: String, latitude: Double = 25.67) -> Place {
    Place(name: name, address: "Monterrey", coordinate: GeoCoordinate(latitude: latitude, longitude: -100.31))
}

import CoreLocation
import NavigationCore

extension LocationTrackingMode {
    var liveConfiguration: CLLocationUpdate.LiveConfiguration {
        switch self {
        case .standard: .default
        case .navigation: .automotiveNavigation
        }
    }

    var keepsRunningInBackground: Bool {
        self == .navigation
    }
}

import Foundation

public enum RoutingError: Error, Equatable {
    case noRouteFound
    case serviceUnavailable
}

extension RoutingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noRouteFound:
            String(localized: "routing.error.noRouteFound", bundle: .module)
        case .serviceUnavailable:
            String(localized: "routing.error.serviceUnavailable", bundle: .module)
        }
    }
}

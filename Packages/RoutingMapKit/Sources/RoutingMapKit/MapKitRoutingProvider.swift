import MapKit
import NavigationCore

public struct MapKitRoutingProvider: RoutingProvider {
    private static let maximumRoutes = 3

    public init() {}

    public func routes(for request: RouteRequest) async throws -> [Route] {
        let response: MKDirections.Response
        do {
            response = try await MKDirections(request: Self.directionsRequest(for: request)).calculate()
        } catch {
            throw Self.routingError(for: error)
        }
        let routes = response.routes
            .prefix(Self.maximumRoutes)
            .enumerated()
            .map { RouteMapper.route(from: $0.element, index: $0.offset) }
        guard !routes.isEmpty else { throw RoutingError.noRouteFound }
        return routes
    }

    private static func directionsRequest(for request: RouteRequest) -> MKDirections.Request {
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = mapItem(at: request.origin)
        directionsRequest.destination = mapItem(at: request.destination)
        directionsRequest.transportType = .automobile
        directionsRequest.requestsAlternateRoutes = true
        directionsRequest.tollPreference = request.avoidsTolls ? .avoid : .any
        return directionsRequest
    }

    private static func mapItem(at coordinate: GeoCoordinate) -> MKMapItem {
        let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return MKMapItem(placemark: MKPlacemark(coordinate: location))
    }

    private static func routingError(for error: Error) -> RoutingError {
        guard let mapKitError = error as? MKError, mapKitError.code == .directionsNotFound else {
            return .serviceUnavailable
        }
        return .noRouteFound
    }
}

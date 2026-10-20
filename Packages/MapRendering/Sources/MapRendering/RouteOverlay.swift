import Foundation
import NavigationCore

public struct RouteOverlay: Equatable, Sendable {
    public static let empty = RouteOverlay(routes: [], selectedRouteID: nil, destination: nil)

    public let routes: [Route]
    public let selectedRouteID: Route.ID?
    public let destination: GeoCoordinate?
    public let traveledDistance: Measurement<UnitLength>?

    public init(
        routes: [Route],
        selectedRouteID: Route.ID?,
        destination: GeoCoordinate?,
        traveledDistance: Measurement<UnitLength>? = nil
    ) {
        self.routes = routes
        self.selectedRouteID = selectedRouteID
        self.destination = destination
        self.traveledDistance = traveledDistance
    }

    var selectedRoute: Route? {
        routes.first { $0.id == selectedRouteID } ?? routes.first
    }
}

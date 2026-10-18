import Foundation
import NavigationCore
import Testing
@testable import MapRendering

struct RouteOverlayTests {
    private let first = makeRoute(id: "first")
    private let second = makeRoute(id: "second")

    @Test func selectsRequestedRoute() {
        let overlay = RouteOverlay(routes: [first, second], selectedRouteID: "second", destination: nil)

        #expect(overlay.selectedRoute?.id == "second")
    }

    @Test func fallsBackToFirstRouteWhenSelectionIsMissing() {
        let overlay = RouteOverlay(routes: [first, second], selectedRouteID: "unknown", destination: nil)

        #expect(overlay.selectedRoute?.id == "first")
    }

    @Test func emptyOverlayHasNoSelection() {
        #expect(RouteOverlay.empty.selectedRoute == nil)
    }

    private static func makeRoute(id: String) -> Route {
        Route(
            id: id,
            name: id,
            polyline: [GeoCoordinate(latitude: 25.67, longitude: -100.31)],
            maneuvers: [],
            distance: Measurement(value: 1, unit: .kilometers),
            expectedTravelTime: .seconds(60)
        )
    }
}

import CarPlay
import MapRendering
import NavigationCore
import PlaceSearch

@MainActor
final class CarPlayTripPlanner {
    struct Plan {
        let place: Place
        let request: RouteRequest
        let routes: [Route]
        let trip: CPTrip
        var selectedRouteID: Route.ID?

        var selectedRoute: Route? {
            routes.first { $0.id == selectedRouteID } ?? routes.first
        }
    }

    private(set) var plan: Plan?

    private let mapTemplate: CPMapTemplate
    private let mapViewController: CarPlayMapViewController
    private let routingProvider: any RoutingProvider
    private let locationTracker: any LocationTracking
    private let recentPlaces: RecentPlacesStore
    private let navigationEngine: NavigationEngine

    init(
        mapTemplate: CPMapTemplate,
        mapViewController: CarPlayMapViewController,
        dependencies: CarPlayDependencies
    ) {
        self.mapTemplate = mapTemplate
        self.mapViewController = mapViewController
        routingProvider = dependencies.routingProvider
        locationTracker = dependencies.locationTracker
        recentPlaces = dependencies.recentPlaces
        navigationEngine = dependencies.navigationEngine
    }

    func planRoute(to place: Place) async throws {
        recentPlaces.record(place)
        guard let origin = await locationTracker.currentSample()?.coordinate else {
            throw CarPlayPlanningError.locationUnavailable
        }
        let request = RouteRequest(origin: origin, destination: place.coordinate)
        let routes = try await routingProvider.routes(for: request)
        let trip = CarPlayTemplateFactory.trip(for: routes, request: request, destinationName: place.name)
        plan = Plan(place: place, request: request, routes: routes, trip: trip, selectedRouteID: routes.first?.id)
        mapTemplate.showTripPreviews([trip], textConfiguration: CarPlayTemplateFactory.previewTextConfiguration())
        showSelectedPlan()
        mapViewController.setCameraMode(.routeOverview)
    }

    func select(_ routeChoice: CPRouteChoice) {
        plan?.selectedRouteID = CarPlayTemplateFactory.routeID(of: routeChoice)
        showSelectedPlan()
    }

    func start(with routeChoice: CPRouteChoice) -> CPTrip? {
        select(routeChoice)
        guard let plan, let route = plan.selectedRoute else { return nil }
        mapTemplate.hideTripPreviews()
        navigationEngine.start(route: route, request: plan.request)
        self.plan = nil
        return plan.trip
    }

    func cancel() {
        guard plan != nil else { return }
        plan = nil
        mapTemplate.hideTripPreviews()
        mapViewController.show(.empty)
        mapViewController.recenter()
    }

    private func showSelectedPlan() {
        guard let plan else { return }
        let overlay = RouteOverlay(
            routes: plan.routes,
            selectedRouteID: plan.selectedRoute?.id,
            destination: plan.place.coordinate
        )
        mapViewController.show(overlay)
        if let route = plan.selectedRoute {
            mapTemplate.updateEstimates(
                CarPlayTemplateFactory.travelEstimates(distance: route.distance, time: route.expectedTravelTime),
                for: plan.trip
            )
        }
    }
}

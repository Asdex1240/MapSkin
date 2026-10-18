import Foundation
import MapRendering
import NavigationCore
import Observation
import PlaceSearch

@MainActor
@Observable
final class HomeModel {
    private static let searchRadius = 20_000.0

    private(set) var searchText = ""
    private(set) var searchResults: [Place] = []
    private(set) var searchErrorMessage: String?
    private(set) var planning: RoutePlanningState?
    private(set) var userLocation: GeoCoordinate?

    let placeSearch: PlaceSearchService
    let recentPlaces: RecentPlacesStore
    let favorites: FavoritesStore
    let navigation: NavigationEngine

    @ObservationIgnored private let routingProvider: any RoutingProvider
    @ObservationIgnored private let locationTracker: any LocationTracking

    init(dependencies: HomeDependencies) {
        placeSearch = dependencies.placeSearch
        recentPlaces = dependencies.recentPlaces
        favorites = dependencies.favorites
        navigation = dependencies.navigationEngine
        routingProvider = dependencies.routingProvider
        locationTracker = dependencies.locationTracker
    }

    var isNavigating: Bool {
        navigation.status != .idle
    }

    var cameraMode: MapCameraMode {
        if isNavigating { return .navigation }
        return planning == nil ? .followingUser : .routeOverview
    }

    var routeOverlay: RouteOverlay {
        if isNavigating, let route = navigation.route {
            return RouteOverlay(routes: [route], selectedRouteID: route.id, destination: route.polyline.last)
        }
        switch planning {
        case .ready(let plan):
            return RouteOverlay(
                routes: plan.routes,
                selectedRouteID: plan.selectedRouteID,
                destination: plan.place.coordinate
            )
        case .loading(let place), .failed(let place, _):
            return RouteOverlay(routes: [], selectedRouteID: nil, destination: place.coordinate)
        case nil:
            return .empty
        }
    }

    func prepare() async {
        locationTracker.requestAuthorization()
        await refreshUserLocation()
    }

    func updateSearchText(_ text: String) {
        searchText = text
        searchResults = []
        searchErrorMessage = nil
        placeSearch.updateQuery(text)
    }

    func submitSearch() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        do {
            searchResults = try await placeSearch.places(matching: query)
            searchErrorMessage = nil
        } catch {
            searchResults = []
            searchErrorMessage = error.localizedDescription
        }
    }

    func choose(_ suggestion: SearchSuggestion) async {
        do {
            await planRoute(to: try await placeSearch.place(for: suggestion))
        } catch {
            searchErrorMessage = error.localizedDescription
        }
    }

    func planRoute(to place: Place) async {
        recentPlaces.record(place)
        planning = .loading(place)
        await refreshUserLocation()
        guard let origin = userLocation else {
            planning = .failed(place, message: String(localized: "routePreview.error.noLocation", bundle: .module))
            return
        }
        let request = RouteRequest(origin: origin, destination: place.coordinate)
        do {
            let routes = try await routingProvider.routes(for: request)
            guard planning == .loading(place) else { return }
            let plan = RoutePlan(place: place, request: request, routes: routes, selectedRouteID: routes.first?.id)
            planning = .ready(plan)
        } catch {
            guard planning == .loading(place) else { return }
            planning = .failed(place, message: error.localizedDescription)
        }
    }

    func selectRoute(_ routeID: Route.ID) {
        guard case .ready(var plan) = planning else { return }
        plan.selectedRouteID = routeID
        planning = .ready(plan)
    }

    func cancelPlanning() {
        planning = nil
    }

    func startNavigation() {
        guard case .ready(let plan) = planning, let route = plan.selectedRoute else { return }
        navigation.start(route: route, request: plan.request)
    }

    func endNavigation() {
        navigation.stop()
        planning = nil
        updateSearchText("")
    }

    func distance(to place: Place) -> Measurement<UnitLength>? {
        userLocation.map { Measurement(value: $0.distance(to: place.coordinate), unit: .meters) }
    }

    private func refreshUserLocation() async {
        guard let sample = await locationTracker.currentSample() else { return }
        userLocation = sample.coordinate
        placeSearch.focus(on: sample.coordinate, radius: Self.searchRadius)
    }
}

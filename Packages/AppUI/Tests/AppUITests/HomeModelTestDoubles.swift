import Foundation
import MapStyle
import NavigationCore
import PlaceSearch
import Testing
import TexturePacks
@testable import AppUI

struct StubRoutingProvider: RoutingProvider {
    let result: Result<[Route], RoutingError>

    func routes(for request: RouteRequest) async throws -> [Route] {
        try result.get()
    }
}

@MainActor
final class FixedLocationTracker: LocationTracking {
    let sample: LocationSample?

    init(sample: LocationSample?) {
        self.sample = sample
    }

    func requestAuthorization() {}

    func samples(for mode: LocationTrackingMode) -> AsyncStream<LocationSample> {
        AsyncStream { _ in }
    }

    func currentSample() async -> LocationSample? {
        sample
    }
}

@MainActor
struct HomeModelFixture {
    static let userLocation = GeoCoordinate(latitude: 25.6714, longitude: -100.3090)
    static let destination = Place(
        name: "Parque Fundidora",
        address: "Monterrey",
        coordinate: GeoCoordinate(latitude: 25.6785, longitude: -100.2840)
    )

    let model: HomeModel
    let navigation: NavigationEngine
    private let suiteName = "AppUITests-\(UUID().uuidString)"

    init(routes: Result<[Route], RoutingError>, location: GeoCoordinate? = Self.userLocation) throws {
        let routing = StubRoutingProvider(result: routes)
        let tracker = FixedLocationTracker(sample: location.map { LocationSample(coordinate: $0, timestamp: .now) })
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        navigation = NavigationEngine(routingProvider: routing, locationTracker: tracker)
        model = HomeModel(
            dependencies: HomeDependencies(
                skinFactory: MapSkinFactory(
                    styleBuilder: MapStyleBuilder(
                        tilesURL: try #require(URL(string: "https://tiles.example.com/planet")),
                        glyphsURL: "https://tiles.example.com/fonts/{fontstack}/{range}.pbf",
                        labelLanguage: "en"
                    )
                ),
                texturePack: try TexturePack.load(
                    from: BundledTexturePacks.packURL(named: BundledTexturePacks.defaultPackName)
                ),
                placeSearch: PlaceSearchService(),
                recentPlaces: RecentPlacesStore(defaults: defaults),
                favorites: FavoritesStore(defaults: defaults),
                routingProvider: routing,
                locationTracker: tracker,
                navigationEngine: navigation
            )
        )
    }

    func tearDown() {
        UserDefaults().removePersistentDomain(forName: suiteName)
    }

    static func route(id: String) -> Route {
        Route(
            id: id,
            name: id,
            polyline: [userLocation, destination.coordinate],
            maneuvers: [
                Maneuver(id: 0, kind: .arrive, instruction: "Arrive", coordinate: destination.coordinate)
            ],
            distance: Measurement(value: 2.6, unit: .kilometers),
            expectedTravelTime: .seconds(420)
        )
    }
}

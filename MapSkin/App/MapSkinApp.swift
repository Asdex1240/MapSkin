import AppUI
import CarPlayUI
import Foundation
import Location
import MapStyle
import NavigationCore
import PlaceSearch
import RoutingMapKit
import SwiftUI
import TexturePacks

@main
struct MapSkinApp: App {
    private let homeDependencies: HomeDependencies
    private let carPlayConnector: CarPlaySceneConnector

    init() {
        let configuration = AppConfiguration(bundle: .main)
        let locationService = LocationService()
        let routingProvider = MapKitRoutingProvider()
        let skinFactory = MapSkinFactory(
            styleBuilder: MapStyleBuilder(
                tilesURL: configuration.mapTilesURL,
                glyphsURL: configuration.mapGlyphsURL,
                labelLanguage: Bundle.main.preferredLocalizations.first ?? "en"
            )
        )
        let textureLibrary = Self.makeTextureLibrary()
        let recentPlaces = RecentPlacesStore(defaults: .standard)
        let favorites = FavoritesStore(defaults: .standard)
        let navigationEngine = NavigationEngine(routingProvider: routingProvider, locationTracker: locationService)

        homeDependencies = HomeDependencies(
            skinFactory: skinFactory,
            textureLibrary: textureLibrary,
            placeSearch: PlaceSearchService(),
            recentPlaces: recentPlaces,
            favorites: favorites,
            routingProvider: routingProvider,
            locationTracker: locationService,
            navigationEngine: navigationEngine,
            defaults: .standard
        )
        carPlayConnector = CarPlaySceneConnector(
            dependencies: CarPlayDependencies(
                skinFactory: skinFactory,
                textureLibrary: textureLibrary,
                recentPlaces: recentPlaces,
                favorites: favorites,
                routingProvider: routingProvider,
                locationTracker: locationService,
                navigationEngine: navigationEngine
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            HomeView(dependencies: homeDependencies)
        }
    }

    private static func makeTextureLibrary() -> TexturePackLibrary {
        do {
            return try TexturePackLibrary(
                defaults: .standard,
                installDirectory: TexturePackLibrary.defaultInstallDirectory()
            )
        } catch {
            preconditionFailure("Bundled texture packs are invalid: \(error)")
        }
    }
}

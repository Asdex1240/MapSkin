import AppUI
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
    private let dependencies: HomeDependencies

    init() {
        let configuration = AppConfiguration(bundle: .main)
        let locationService = LocationService()
        let routingProvider = MapKitRoutingProvider()
        dependencies = HomeDependencies(
            skinFactory: MapSkinFactory(
                styleBuilder: MapStyleBuilder(
                    tilesURL: configuration.mapTilesURL,
                    glyphsURL: configuration.mapGlyphsURL,
                    labelLanguage: Bundle.main.preferredLocalizations.first ?? "en"
                )
            ),
            textureLibrary: Self.makeTextureLibrary(),
            placeSearch: PlaceSearchService(),
            recentPlaces: RecentPlacesStore(defaults: .standard),
            favorites: FavoritesStore(defaults: .standard),
            routingProvider: routingProvider,
            locationTracker: locationService,
            navigationEngine: NavigationEngine(routingProvider: routingProvider, locationTracker: locationService),
            defaults: .standard
        )
    }

    var body: some Scene {
        WindowGroup {
            HomeView(dependencies: dependencies)
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

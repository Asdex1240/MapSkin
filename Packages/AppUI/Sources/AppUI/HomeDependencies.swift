import Foundation
import MapStyle
import NavigationCore
import PlaceSearch
import TexturePacks

@MainActor
public struct HomeDependencies {
    let skinFactory: MapSkinFactory
    let textureLibrary: TexturePackLibrary
    let placeSearch: PlaceSearchService
    let recentPlaces: RecentPlacesStore
    let favorites: FavoritesStore
    let routingProvider: any RoutingProvider
    let locationTracker: any LocationTracking
    let navigationEngine: NavigationEngine
    let defaults: UserDefaults

    public init(
        skinFactory: MapSkinFactory,
        textureLibrary: TexturePackLibrary,
        placeSearch: PlaceSearchService,
        recentPlaces: RecentPlacesStore,
        favorites: FavoritesStore,
        routingProvider: any RoutingProvider,
        locationTracker: any LocationTracking,
        navigationEngine: NavigationEngine,
        defaults: UserDefaults
    ) {
        self.skinFactory = skinFactory
        self.textureLibrary = textureLibrary
        self.placeSearch = placeSearch
        self.recentPlaces = recentPlaces
        self.favorites = favorites
        self.routingProvider = routingProvider
        self.locationTracker = locationTracker
        self.navigationEngine = navigationEngine
        self.defaults = defaults
    }
}

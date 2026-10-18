import MapStyle
import NavigationCore
import PlaceSearch
import TexturePacks

@MainActor
public struct CarPlayDependencies {
    let skinFactory: MapSkinFactory
    let textureLibrary: TexturePackLibrary
    let recentPlaces: RecentPlacesStore
    let favorites: FavoritesStore
    let routingProvider: any RoutingProvider
    let locationTracker: any LocationTracking
    let navigationEngine: NavigationEngine

    public init(
        skinFactory: MapSkinFactory,
        textureLibrary: TexturePackLibrary,
        recentPlaces: RecentPlacesStore,
        favorites: FavoritesStore,
        routingProvider: any RoutingProvider,
        locationTracker: any LocationTracking,
        navigationEngine: NavigationEngine
    ) {
        self.skinFactory = skinFactory
        self.textureLibrary = textureLibrary
        self.recentPlaces = recentPlaces
        self.favorites = favorites
        self.routingProvider = routingProvider
        self.locationTracker = locationTracker
        self.navigationEngine = navigationEngine
    }
}

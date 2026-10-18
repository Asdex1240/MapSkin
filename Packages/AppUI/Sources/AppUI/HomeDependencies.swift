import MapStyle
import NavigationCore
import PlaceSearch
import TexturePacks

@MainActor
public struct HomeDependencies {
    let skinFactory: MapSkinFactory
    let texturePack: TexturePack
    let placeSearch: PlaceSearchService
    let recentPlaces: RecentPlacesStore
    let favorites: FavoritesStore
    let routingProvider: any RoutingProvider
    let locationTracker: any LocationTracking
    let navigationEngine: NavigationEngine

    public init(
        skinFactory: MapSkinFactory,
        texturePack: TexturePack,
        placeSearch: PlaceSearchService,
        recentPlaces: RecentPlacesStore,
        favorites: FavoritesStore,
        routingProvider: any RoutingProvider,
        locationTracker: any LocationTracking,
        navigationEngine: NavigationEngine
    ) {
        self.skinFactory = skinFactory
        self.texturePack = texturePack
        self.placeSearch = placeSearch
        self.recentPlaces = recentPlaces
        self.favorites = favorites
        self.routingProvider = routingProvider
        self.locationTracker = locationTracker
        self.navigationEngine = navigationEngine
    }
}

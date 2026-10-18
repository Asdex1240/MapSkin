import CarPlay
import NavigationCore
import PlaceSearch

@MainActor
final class CarPlayDestinations: NSObject {
    private static let maximumSavedItems = 12
    private static let searchRadius = 20_000.0

    private let interfaceController: CPInterfaceController
    private let placeSearch = PlaceSearchService()
    private let recentPlaces: RecentPlacesStore
    private let favorites: FavoritesStore
    private let locationTracker: any LocationTracking
    private let onChoose: (Place) -> Void
    private var resultsByItem: [ObjectIdentifier: Place] = [:]
    private var searchTask: Task<Void, Never>?

    init(
        interfaceController: CPInterfaceController,
        recentPlaces: RecentPlacesStore,
        favorites: FavoritesStore,
        locationTracker: any LocationTracking,
        onChoose: @escaping (Place) -> Void
    ) {
        self.interfaceController = interfaceController
        self.recentPlaces = recentPlaces
        self.favorites = favorites
        self.locationTracker = locationTracker
        self.onChoose = onChoose
    }

    func showSearch() {
        let template = CPSearchTemplate()
        template.delegate = self
        interfaceController.pushTemplate(template, animated: true, completion: nil)
        Task { await focusOnUserLocation() }
    }

    func showSaved() {
        let template = CPListTemplate(
            title: String(localized: "carPlay.destinations", bundle: .module),
            sections: savedSections()
        )
        template.emptyViewTitleVariants = [String(localized: "carPlay.saved.empty", bundle: .module)]
        interfaceController.pushTemplate(template, animated: true, completion: nil)
    }

    private func savedSections() -> [CPListSection] {
        let favoriteItems = favorites.favorites.prefix(Self.maximumSavedItems).map { favorite in
            item(for: favorite.place, title: title(of: favorite), symbol: symbol(of: favorite))
        }
        let recentItems = recentPlaces.places.prefix(Self.maximumSavedItems).map { place in
            item(for: place, title: place.name, symbol: "clock.arrow.circlepath")
        }
        return [
            (String(localized: "carPlay.favorites", bundle: .module), favoriteItems),
            (String(localized: "carPlay.recents", bundle: .module), recentItems)
        ]
        .filter { !$0.1.isEmpty }
        .map { CPListSection(items: $0.1, header: $0.0, sectionIndexTitle: nil) }
    }

    private func item(for place: Place, title: String, symbol: String) -> CPListItem {
        let item = CPListItem(text: title, detailText: place.address, image: UIImage(systemName: symbol))
        item.handler = { [weak self] _, completion in
            self?.onChoose(place)
            completion()
        }
        return item
    }

    private func title(of favorite: Favorite) -> String {
        switch favorite.role {
        case .home: String(localized: "carPlay.favorites.home", bundle: .module)
        case .work: String(localized: "carPlay.favorites.work", bundle: .module)
        case .custom: favorite.place.name
        }
    }

    private func symbol(of favorite: Favorite) -> String {
        switch favorite.role {
        case .home: "house.fill"
        case .work: "briefcase.fill"
        case .custom: "star.fill"
        }
    }

    private func focusOnUserLocation() async {
        guard let coordinate = await locationTracker.currentSample()?.coordinate else { return }
        placeSearch.focus(on: coordinate, radius: Self.searchRadius)
    }
}

extension CarPlayDestinations: CPSearchTemplateDelegate {
    func searchTemplate(
        _ searchTemplate: CPSearchTemplate,
        updatedSearchText searchText: String,
        completionHandler: @escaping ([CPListItem]) -> Void
    ) {
        searchTask?.cancel()
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            completionHandler([])
            return
        }
        searchTask = Task { [weak self] in
            guard let self else { return }
            let places = (try? await self.placeSearch.places(matching: query)) ?? []
            guard !Task.isCancelled else { return }
            let items = places.prefix(Self.maximumSavedItems).map { place in
                CPListItem(text: place.name, detailText: place.address)
            }
            self.resultsByItem = Dictionary(uniqueKeysWithValues: zip(items.map(ObjectIdentifier.init), places))
            completionHandler(Array(items))
        }
    }

    func searchTemplate(
        _ searchTemplate: CPSearchTemplate,
        selectedResult item: CPListItem,
        completionHandler: @escaping () -> Void
    ) {
        if let place = resultsByItem[ObjectIdentifier(item)] {
            onChoose(place)
        }
        completionHandler()
    }
}

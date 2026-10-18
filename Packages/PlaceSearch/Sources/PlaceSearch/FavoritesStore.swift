import Foundation
import Observation

@MainActor
@Observable
public final class FavoritesStore {
    public private(set) var favorites: [Favorite]

    @ObservationIgnored private let storage: StoredValue<[Favorite]>

    public init(defaults: UserDefaults) {
        storage = StoredValue(defaults: defaults, key: "favoritePlaces")
        favorites = Self.sorted(storage.load() ?? [])
    }

    public var home: Favorite? { favorites.first { $0.role == .home } }
    public var work: Favorite? { favorites.first { $0.role == .work } }
    public var custom: [Favorite] { favorites.filter { $0.role == .custom } }

    public func save(_ place: Place, as role: Favorite.Role) {
        var updated = favorites
        switch role {
        case .home, .work:
            updated.removeAll { $0.role == role }
        case .custom:
            updated.removeAll { $0.role == .custom && $0.place.id == place.id }
        }
        updated.append(Favorite(role: role, place: place))
        persist(updated)
    }

    public func remove(_ favorite: Favorite) {
        persist(favorites.filter { $0.id != favorite.id })
    }

    public func contains(_ place: Place) -> Bool {
        favorites.contains { $0.place.id == place.id }
    }

    private func persist(_ updated: [Favorite]) {
        favorites = Self.sorted(updated)
        storage.save(favorites)
    }

    private static func sorted(_ favorites: [Favorite]) -> [Favorite] {
        let order: [Favorite.Role] = [.home, .work, .custom]
        return favorites.enumerated()
            .sorted { lhs, rhs in
                let lhsRank = order.firstIndex(of: lhs.element.role) ?? order.count
                let rhsRank = order.firstIndex(of: rhs.element.role) ?? order.count
                return lhsRank == rhsRank ? lhs.offset < rhs.offset : lhsRank < rhsRank
            }
            .map(\.element)
    }
}

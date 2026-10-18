import Foundation
import Observation

@MainActor
@Observable
public final class RecentPlacesStore {
    public static let maximumCount = 20

    public private(set) var places: [Place]

    @ObservationIgnored private let storage: StoredValue<[Place]>

    public init(defaults: UserDefaults) {
        storage = StoredValue(defaults: defaults, key: "recentPlaces")
        places = storage.load() ?? []
    }

    public func record(_ place: Place) {
        places = Array(([place] + places.filter { $0.id != place.id }).prefix(Self.maximumCount))
        storage.save(places)
    }

    public func remove(_ place: Place) {
        places.removeAll { $0.id == place.id }
        storage.save(places)
    }

    public func removeAll() {
        places = []
        storage.save(places)
    }
}

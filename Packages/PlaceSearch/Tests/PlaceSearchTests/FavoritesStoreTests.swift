import PlaceSearch
import Testing

@MainActor
struct FavoritesStoreTests {
    @Test func replacesPreviousHome() {
        let storage = TestDefaults()
        defer { storage.clear() }
        let store = FavoritesStore(defaults: storage.defaults)

        store.save(makePlace("Old home"), as: .home)
        store.save(makePlace("New home", latitude: 25.7), as: .home)

        #expect(store.home?.place.name == "New home")
        #expect(store.favorites.count == 1)
    }

    @Test func listsHomeAndWorkBeforeCustomPlaces() {
        let storage = TestDefaults()
        defer { storage.clear() }
        let store = FavoritesStore(defaults: storage.defaults)

        store.save(makePlace("Gym"), as: .custom)
        store.save(makePlace("Office", latitude: 25.7), as: .work)
        store.save(makePlace("House", latitude: 25.8), as: .home)

        #expect(store.favorites.map(\.role) == [.home, .work, .custom])
    }

    @Test func doesNotDuplicateCustomPlaces() {
        let storage = TestDefaults()
        defer { storage.clear() }
        let store = FavoritesStore(defaults: storage.defaults)

        store.save(makePlace("Gym"), as: .custom)
        store.save(makePlace("Gym"), as: .custom)

        #expect(store.custom.count == 1)
    }

    @Test func removesFavorite() throws {
        let storage = TestDefaults()
        defer { storage.clear() }
        let store = FavoritesStore(defaults: storage.defaults)
        store.save(makePlace("House"), as: .home)

        store.remove(try #require(store.home))

        #expect(store.home == nil)
        #expect(!store.contains(makePlace("House")))
    }

    @Test func persistsAcrossLaunches() {
        let storage = TestDefaults()
        defer { storage.clear() }
        FavoritesStore(defaults: storage.defaults).save(makePlace("Office"), as: .work)

        let reloaded = FavoritesStore(defaults: storage.defaults)

        #expect(reloaded.work?.place.name == "Office")
    }
}

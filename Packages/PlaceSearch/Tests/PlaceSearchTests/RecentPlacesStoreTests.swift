import PlaceSearch
import Testing

@MainActor
struct RecentPlacesStoreTests {
    @Test func putsMostRecentPlaceFirst() {
        let storage = TestDefaults()
        defer { storage.clear() }
        let store = RecentPlacesStore(defaults: storage.defaults)

        store.record(makePlace("Macroplaza"))
        store.record(makePlace("Fundidora"))

        #expect(store.places.map(\.name) == ["Fundidora", "Macroplaza"])
    }

    @Test func movesRepeatedPlaceToTheTop() {
        let storage = TestDefaults()
        defer { storage.clear() }
        let store = RecentPlacesStore(defaults: storage.defaults)

        store.record(makePlace("Macroplaza"))
        store.record(makePlace("Fundidora"))
        store.record(makePlace("Macroplaza"))

        #expect(store.places.map(\.name) == ["Macroplaza", "Fundidora"])
    }

    @Test func keepsAtMostTwentyPlaces() {
        let storage = TestDefaults()
        defer { storage.clear() }
        let store = RecentPlacesStore(defaults: storage.defaults)

        for index in 0..<25 {
            store.record(makePlace("Place \(index)"))
        }

        #expect(store.places.count == RecentPlacesStore.maximumCount)
        #expect(store.places.first?.name == "Place 24")
        #expect(store.places.last?.name == "Place 5")
    }

    @Test func persistsAcrossLaunches() {
        let storage = TestDefaults()
        defer { storage.clear() }
        RecentPlacesStore(defaults: storage.defaults).record(makePlace("Macroplaza"))

        let reloaded = RecentPlacesStore(defaults: storage.defaults)

        #expect(reloaded.places.map(\.name) == ["Macroplaza"])
    }

    @Test func removesPlaces() {
        let storage = TestDefaults()
        defer { storage.clear() }
        let store = RecentPlacesStore(defaults: storage.defaults)
        store.record(makePlace("Macroplaza"))
        store.record(makePlace("Fundidora"))

        store.remove(makePlace("Macroplaza"))

        #expect(store.places.map(\.name) == ["Fundidora"])
    }
}

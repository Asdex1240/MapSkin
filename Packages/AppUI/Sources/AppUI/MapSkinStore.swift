import MapStyle
import Observation
import OSLog
import TexturePacks

@MainActor
@Observable
final class MapSkinStore {
    private(set) var skin: MapSkin?

    @ObservationIgnored private let factory: MapSkinFactory
    @ObservationIgnored private let library: TexturePackLibrary
    @ObservationIgnored private var cachedSkins: [MapSkin.ID: MapSkin] = [:]
    @ObservationIgnored private var cachedPackID: TexturePack.ID?
    @ObservationIgnored private let logger = Logger(subsystem: "MapSkin", category: "MapSkinStore")

    init(factory: MapSkinFactory, library: TexturePackLibrary) {
        self.factory = factory
        self.library = library
    }

    func loadSkin(for appearance: MapAppearance, screenScale: Double) async {
        let pack = library.activePack
        if cachedPackID != pack.id {
            cachedSkins = [:]
            cachedPackID = pack.id
        }
        let skinID = MapSkinFactory.skinID(for: pack, appearance: appearance, screenScale: screenScale)
        if let cached = cachedSkins[skinID] {
            skin = cached
            return
        }
        do {
            let built = try await factory.makeSkin(pack: pack, appearance: appearance, screenScale: screenScale)
            guard library.activePack.id == pack.id else { return }
            cachedSkins[built.id] = built
            skin = built
        } catch {
            logger.error("Could not build map skin for pack \(pack.id): \(error.localizedDescription)")
        }
    }
}

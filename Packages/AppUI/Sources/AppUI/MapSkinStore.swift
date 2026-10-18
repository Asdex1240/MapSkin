import MapStyle
import Observation
import OSLog
import TexturePacks

@MainActor
@Observable
final class MapSkinStore {
    private(set) var skin: MapSkin?

    private let factory: MapSkinFactory
    private let pack: TexturePack
    private let logger = Logger(subsystem: "MapSkin", category: "MapSkinStore")

    init(factory: MapSkinFactory, pack: TexturePack) {
        self.factory = factory
        self.pack = pack
    }

    func loadSkin(for appearance: MapAppearance, screenScale: Double) async {
        do {
            skin = try await factory.makeSkin(pack: pack, appearance: appearance, screenScale: screenScale)
        } catch {
            logger.error("Could not build map skin for pack \(self.pack.id): \(error.localizedDescription)")
        }
    }
}

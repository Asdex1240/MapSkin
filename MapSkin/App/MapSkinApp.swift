import AppUI
import Foundation
import MapStyle
import SwiftUI
import TexturePacks

@main
struct MapSkinApp: App {
    private let skinFactory: MapSkinFactory
    private let defaultTexturePack: TexturePack

    init() {
        let configuration = AppConfiguration(bundle: .main)
        skinFactory = MapSkinFactory(
            styleBuilder: MapStyleBuilder(
                tilesURL: configuration.mapTilesURL,
                glyphsURL: configuration.mapGlyphsURL,
                labelLanguage: Bundle.main.preferredLocalizations.first ?? "en"
            )
        )
        defaultTexturePack = Self.loadDefaultTexturePack()
    }

    var body: some Scene {
        WindowGroup {
            HomeView(skinFactory: skinFactory, texturePack: defaultTexturePack)
        }
    }

    private static func loadDefaultTexturePack() -> TexturePack {
        do {
            return try TexturePack.load(from: BundledTexturePacks.packURL(named: BundledTexturePacks.defaultPackName))
        } catch {
            preconditionFailure("Bundled default texture pack is invalid: \(error)")
        }
    }
}

import Foundation

struct AppConfiguration: Sendable {
    private enum InfoKey: String {
        case mapTilesURL = "MapTilesURL"
        case mapGlyphsURL = "MapGlyphsURL"
    }

    let mapTilesURL: URL
    let mapGlyphsURL: String

    init(bundle: Bundle) {
        let tiles = Self.value(for: .mapTilesURL, in: bundle)
        guard let tilesURL = URL(string: tiles) else {
            preconditionFailure("\(InfoKey.mapTilesURL.rawValue) is not a valid URL")
        }
        mapTilesURL = tilesURL
        mapGlyphsURL = Self.value(for: .mapGlyphsURL, in: bundle)
    }

    private static func value(for key: InfoKey, in bundle: Bundle) -> String {
        guard let value = bundle.object(forInfoDictionaryKey: key.rawValue) as? String, !value.isEmpty else {
            preconditionFailure("\(key.rawValue) is missing in Info.plist")
        }
        return value
    }
}

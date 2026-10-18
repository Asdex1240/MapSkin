import Foundation

struct AppConfiguration: Sendable {
    private static let mapStyleURLKey = "MapStyleURL"

    let mapStyleURL: URL

    init(bundle: Bundle) {
        guard
            let value = bundle.object(forInfoDictionaryKey: Self.mapStyleURLKey) as? String,
            let url = URL(string: value)
        else {
            preconditionFailure("\(Self.mapStyleURLKey) is missing or invalid in Info.plist")
        }
        mapStyleURL = url
    }
}

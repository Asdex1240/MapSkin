import Foundation

public enum PlaceSearchError: Error, Equatable {
    case noResults
    case serviceUnavailable
}

extension PlaceSearchError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noResults:
            String(localized: "search.error.noResults", bundle: .module)
        case .serviceUnavailable:
            String(localized: "search.error.serviceUnavailable", bundle: .module)
        }
    }
}

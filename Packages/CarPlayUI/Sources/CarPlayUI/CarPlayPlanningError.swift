import Foundation

enum CarPlayPlanningError: Error {
    case locationUnavailable
}

extension CarPlayPlanningError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .locationUnavailable:
            String(localized: "carPlay.error.noLocation", bundle: .module)
        }
    }
}

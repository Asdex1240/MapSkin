import SwiftUI

enum SheetPosition {
    case collapsed
    case medium
    case large

    init(_ detent: PresentationDetent) {
        switch detent {
        case .medium: self = .medium
        case .large: self = .large
        default: self = .collapsed
        }
    }

    func detent(collapsedHeight: Double) -> PresentationDetent {
        switch self {
        case .collapsed: .height(collapsedHeight)
        case .medium: .medium
        case .large: .large
        }
    }
}

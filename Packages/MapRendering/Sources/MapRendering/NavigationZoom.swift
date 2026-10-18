enum NavigationZoom {
    static let pitch = 45.0

    static func level(forSpeed metersPerSecond: Double?) -> Double {
        switch metersPerSecond ?? 0 {
        case ..<8: 17
        case ..<17: 16
        case ..<25: 15.5
        default: 15
        }
    }
}

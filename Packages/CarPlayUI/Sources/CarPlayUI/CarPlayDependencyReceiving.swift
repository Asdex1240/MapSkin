import Foundation

@MainActor
public protocol CarPlayDependencyReceiving: AnyObject {
    func receive(_ dependencies: CarPlayDependencies)
}

public extension CarPlayDependencyReceiving {
    func requestDependencies() {
        NotificationCenter.default.post(name: .carPlayDependenciesRequested, object: self)
    }
}

extension Notification.Name {
    static let carPlayDependenciesRequested = Notification.Name("MapSkin.carPlayDependenciesRequested")
}

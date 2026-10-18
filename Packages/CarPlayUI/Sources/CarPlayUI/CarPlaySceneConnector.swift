import Foundation
import OSLog

@MainActor
public final class CarPlaySceneConnector: NSObject {
    private let dependencies: CarPlayDependencies
    private let logger = Logger(subsystem: "MapSkin", category: "CarPlay")

    public init(dependencies: CarPlayDependencies) {
        self.dependencies = dependencies
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dependenciesRequested(_:)),
            name: .carPlayDependenciesRequested,
            object: nil
        )
    }

    @objc private func dependenciesRequested(_ notification: Notification) {
        guard let receiver = notification.object as? CarPlayDependencyReceiving else {
            logger.error("Ignored a CarPlay dependency request without a receiver")
            return
        }
        logger.info("Providing dependencies to the CarPlay scene")
        receiver.receive(dependencies)
    }
}

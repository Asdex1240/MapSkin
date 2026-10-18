import CarPlay
import CarPlayUI
import OSLog
import UIKit

final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate, CarPlayDependencyReceiving {
    private let logger = Logger(subsystem: "MapSkin", category: "CarPlay")
    private var dependencies: CarPlayDependencies?
    private var interfaceController: CPInterfaceController?
    private var window: CPWindow?
    private var coordinator: CarPlayCoordinator?

    func receive(_ dependencies: CarPlayDependencies) {
        guard self.dependencies == nil else { return }
        logger.info("CarPlay scene received dependencies")
        self.dependencies = dependencies
        startIfReady()
    }

    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController,
        to window: CPWindow
    ) {
        logger.info("CarPlay scene connected")
        self.interfaceController = interfaceController
        self.window = window
        if dependencies == nil {
            requestDependencies()
        }
        startIfReady()
    }

    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController,
        from window: CPWindow
    ) {
        logger.info("CarPlay scene disconnected")
        coordinator?.disconnect()
        coordinator = nil
        self.interfaceController = nil
        self.window = nil
    }

    private func startIfReady() {
        guard coordinator == nil, let dependencies, let interfaceController, let window else { return }
        logger.info("Starting the CarPlay coordinator")
        let coordinator = CarPlayCoordinator(
            interfaceController: interfaceController,
            window: window,
            dependencies: dependencies
        )
        self.coordinator = coordinator
        coordinator.start()
    }
}

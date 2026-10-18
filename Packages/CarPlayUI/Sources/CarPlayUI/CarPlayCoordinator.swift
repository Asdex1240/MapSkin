import CarPlay
import OSLog
import PlaceSearch
import UIKit

@MainActor
public final class CarPlayCoordinator: NSObject {
    private enum Mode {
        case browsing
        case previewing
        case navigating
    }

    private let interfaceController: CPInterfaceController
    private let mapTemplate = CPMapTemplate()
    private let mapViewController: CarPlayMapViewController
    private let logger = Logger(subsystem: "MapSkin", category: "CarPlay")
    private var destinations: CarPlayDestinations?
    private var tripPlanner: CarPlayTripPlanner?
    private var guidance: CarPlayGuidance?
    private var isGuidanceStarted = false

    public init(interfaceController: CPInterfaceController, window: CPWindow, dependencies: CarPlayDependencies) {
        self.interfaceController = interfaceController
        mapViewController = CarPlayMapViewController(
            skinFactory: dependencies.skinFactory,
            library: dependencies.textureLibrary
        )
        super.init()
        window.rootViewController = mapViewController
        destinations = CarPlayDestinations(
            interfaceController: interfaceController,
            recentPlaces: dependencies.recentPlaces,
            favorites: dependencies.favorites,
            locationTracker: dependencies.locationTracker
        ) { [weak self] place in
            self?.planRoute(to: place)
        }
        tripPlanner = CarPlayTripPlanner(
            mapTemplate: mapTemplate,
            mapViewController: mapViewController,
            dependencies: dependencies
        )
        guidance = CarPlayGuidance(
            mapTemplate: mapTemplate,
            mapViewController: mapViewController,
            engine: dependencies.navigationEngine
        ) { [weak self] isActive in
            self?.apply(isActive ? .navigating : .browsing)
        }
    }

    public func start() {
        interfaceController.delegate = self
        mapTemplate.mapDelegate = self
        mapTemplate.automaticallyHidesNavigationBar = false
        apply(.browsing)
        interfaceController.setRootTemplate(mapTemplate, animated: false) { [logger] success, error in
            if success {
                logger.info("CarPlay map template set as root")
            } else {
                logger.error("Could not set the CarPlay root template: \(String(describing: error))")
            }
        }
    }

    public func disconnect() {
        guidance?.stop()
        mapViewController.stopObserving()
    }

    private func planRoute(to place: Place) {
        interfaceController.popToRootTemplate(animated: true, completion: nil)
        Task {
            do {
                try await tripPlanner?.planRoute(to: place)
                apply(.previewing)
            } catch {
                logger.error("CarPlay route planning failed: \(error.localizedDescription)")
                presentError(error.localizedDescription)
            }
        }
    }

    private func apply(_ mode: Mode) {
        switch mode {
        case .browsing:
            mapTemplate.leadingNavigationBarButtons = [searchButton, destinationsButton]
            mapTemplate.trailingNavigationBarButtons = [panButton]
            mapTemplate.mapButtons = [recenterButton, zoomInButton, zoomOutButton]
        case .previewing:
            mapTemplate.leadingNavigationBarButtons = [cancelButton]
            mapTemplate.trailingNavigationBarButtons = []
            mapTemplate.mapButtons = [zoomInButton, zoomOutButton]
        case .navigating:
            mapTemplate.leadingNavigationBarButtons = []
            mapTemplate.trailingNavigationBarButtons = [endButton]
            mapTemplate.mapButtons = [recenterButton, zoomInButton, zoomOutButton]
        }
    }

    private func presentError(_ message: String) {
        let alert = CPAlertTemplate(
            titleVariants: [message],
            actions: [
                CPAlertAction(title: String(localized: "carPlay.ok", bundle: .module), style: .cancel) {
                    [weak self] _ in
                    self?.interfaceController.dismissTemplate(animated: true, completion: nil)
                }
            ]
        )
        interfaceController.presentTemplate(alert, animated: true, completion: nil)
    }

    private var searchButton: CPBarButton {
        CPBarButton(title: String(localized: "carPlay.search", bundle: .module)) { [weak self] _ in
            self?.destinations?.showSearch()
        }
    }

    private var destinationsButton: CPBarButton {
        CPBarButton(title: String(localized: "carPlay.destinations", bundle: .module)) { [weak self] _ in
            self?.destinations?.showSaved()
        }
    }

    private var panButton: CPBarButton {
        CPBarButton(title: String(localized: "carPlay.pan", bundle: .module)) { [weak self] _ in
            self?.mapTemplate.showPanningInterface(animated: true)
        }
    }

    private var cancelButton: CPBarButton {
        CPBarButton(title: String(localized: "carPlay.cancel", bundle: .module)) { [weak self] _ in
            self?.tripPlanner?.cancel()
            self?.apply(.browsing)
        }
    }

    private var endButton: CPBarButton {
        CPBarButton(title: String(localized: "carPlay.end", bundle: .module)) { [weak self] _ in
            self?.guidance?.endFromCarPlay()
        }
    }

    private var recenterButton: CPMapButton {
        mapButton(symbol: "location.fill") { [weak self] in self?.mapViewController.recenter() }
    }

    private var zoomInButton: CPMapButton {
        mapButton(symbol: "plus.magnifyingglass") { [weak self] in self?.mapViewController.zoomIn() }
    }

    private var zoomOutButton: CPMapButton {
        mapButton(symbol: "minus.magnifyingglass") { [weak self] in self?.mapViewController.zoomOut() }
    }

    private func mapButton(symbol: String, action: @escaping () -> Void) -> CPMapButton {
        let button = CPMapButton { _ in action() }
        button.image = UIImage(systemName: symbol)
        return button
    }
}

extension CarPlayCoordinator: CPMapTemplateDelegate {
    public func mapTemplate(_ mapTemplate: CPMapTemplate, panWith direction: CPMapTemplate.PanDirection) {
        mapViewController.pan(direction)
    }

    public func mapTemplate(
        _ mapTemplate: CPMapTemplate,
        selectedPreviewFor trip: CPTrip,
        using routeChoice: CPRouteChoice
    ) {
        tripPlanner?.select(routeChoice)
    }

    public func mapTemplate(_ mapTemplate: CPMapTemplate, startedTrip trip: CPTrip, using routeChoice: CPRouteChoice) {
        guard let startedTrip = tripPlanner?.start(with: routeChoice) else { return }
        guidance?.prepare(startedTrip)
    }

    public func mapTemplateDidCancelNavigation(_ mapTemplate: CPMapTemplate) {
        guidance?.endFromCarPlay()
    }

    @available(iOS 26.4, *)
    public func mapTemplateShouldProvideRouteSharing(_ mapTemplate: CPMapTemplate) -> Bool {
        false
    }
}

extension CarPlayCoordinator: CPInterfaceControllerDelegate {
    public func templateDidAppear(_ aTemplate: CPTemplate, animated: Bool) {
        guard aTemplate === mapTemplate, !isGuidanceStarted else { return }
        logger.info("CarPlay map template appeared; starting guidance sync")
        isGuidanceStarted = true
        guidance?.start()
    }
}

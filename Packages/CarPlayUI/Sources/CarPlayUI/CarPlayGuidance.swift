import CarPlay
import MapRendering
import NavigationCore

@MainActor
final class CarPlayGuidance {
    private static let alertDuration: TimeInterval = 5

    private let mapTemplate: CPMapTemplate
    private let mapViewController: CarPlayMapViewController
    private let engine: NavigationEngine
    private let onActiveChange: (Bool) -> Void
    private var session: CPNavigationSession?
    private var preparedTrip: CPTrip?
    private var shownManeuverIDs: [Maneuver.ID] = []
    private var shownRouteID: Route.ID?
    private var observations: [any ObservationCancelling] = []

    init(
        mapTemplate: CPMapTemplate,
        mapViewController: CarPlayMapViewController,
        engine: NavigationEngine,
        onActiveChange: @escaping (Bool) -> Void
    ) {
        self.mapTemplate = mapTemplate
        self.mapViewController = mapViewController
        self.engine = engine
        self.onActiveChange = onActiveChange
    }

    var isActive: Bool {
        session != nil
    }

    func start() {
        observations = [
            ObservedValue({ [engine] in engine.status }) { [weak self] status in
                self?.statusChanged(to: status)
            },
            ObservedValue({ [engine] in engine.progress }) { [weak self] progress in
                self?.progressChanged(to: progress)
            }
        ]
    }

    func stop() {
        observations.forEach { $0.cancel() }
        observations = []
    }

    func prepare(_ trip: CPTrip) {
        preparedTrip = trip
    }

    func endFromCarPlay() {
        engine.stop()
    }

    private func statusChanged(to status: NavigationStatus) {
        switch status {
        case .idle:
            endSession(arrived: false)
        case .navigating:
            if session == nil {
                beginSession()
            }
        case .rerouting:
            session?.pauseTrip(for: .rerouting, description: String(localized: "carPlay.rerouting", bundle: .module))
            presentAlert(title: String(localized: "carPlay.rerouting", bundle: .module), action: nil)
        case .arrived:
            presentArrival()
        }
    }

    private func beginSession() {
        guard let route = engine.route, let request = engine.request else { return }
        let trip = preparedTrip ?? CarPlayTemplateFactory.trip(for: [route], request: request, destinationName: nil)
        preparedTrip = nil
        mapTemplate.hideTripPreviews()
        session = mapTemplate.startNavigationSession(for: trip)
        shownManeuverIDs = []
        shownRouteID = nil
        mapViewController.setCameraMode(.navigation)
        onActiveChange(true)
        progressChanged(to: engine.progress)
    }

    private func endSession(arrived: Bool) {
        guard let session else { return }
        if arrived {
            session.finishTrip()
        } else {
            session.cancelTrip()
        }
        self.session = nil
        mapViewController.show(.empty)
        mapViewController.setCameraMode(.followingUser)
        onActiveChange(false)
    }

    private func progressChanged(to progress: NavigationProgress?) {
        guard let session, let progress, let route = engine.route else { return }
        if route.id != shownRouteID {
            shownRouteID = route.id
            let overlay = RouteOverlay(routes: [route], selectedRouteID: route.id, destination: route.polyline.last)
            mapViewController.show(overlay)
        }
        updateManeuvers(in: session, progress: progress)
        if let sample = progress.location {
            mapViewController.moveNavigationCamera(to: sample)
        }
        let tripEstimates = CarPlayTemplateFactory.travelEstimates(
            distance: progress.remainingDistance,
            time: progress.remainingTravelTime
        )
        mapTemplate.updateEstimates(tripEstimates, for: session.trip)
    }

    private func updateManeuvers(in session: CPNavigationSession, progress: NavigationProgress) {
        let maneuvers = UpcomingManeuvers.visible(next: progress.nextManeuver, following: progress.followingManeuver)
        let timeToNext = timeToNextManeuver(progress)
        if maneuvers.map(\.id) != shownManeuverIDs {
            shownManeuverIDs = maneuvers.map(\.id)
            let carPlayManeuvers = maneuvers.map {
                CarPlayTemplateFactory.maneuver(for: $0, distance: progress.distanceToNextManeuver, time: timeToNext)
            }
            if #available(iOS 17.4, *) {
                session.add(carPlayManeuvers)
            }
            session.upcomingManeuvers = carPlayManeuvers
        }
        if let current = session.upcomingManeuvers.first {
            session.updateEstimates(
                CarPlayTemplateFactory.travelEstimates(distance: progress.distanceToNextManeuver, time: timeToNext),
                for: current
            )
        }
    }

    private func timeToNextManeuver(_ progress: NavigationProgress) -> Duration {
        let remaining = progress.remainingDistance.converted(to: .meters).value
        guard remaining > 0 else { return .zero }
        let fraction = progress.distanceToNextManeuver.converted(to: .meters).value / remaining
        return progress.remainingTravelTime * fraction
    }

    private func presentArrival() {
        let done = CPAlertAction(title: String(localized: "carPlay.arrived.done", bundle: .module), style: .default) {
            [weak self] _ in
            self?.endSession(arrived: true)
            self?.engine.stop()
        }
        presentAlert(title: String(localized: "carPlay.arrived.title", bundle: .module), action: done)
    }

    private func presentAlert(title: String, action: CPAlertAction?) {
        let alert = CPNavigationAlert(
            titleVariants: [title],
            subtitleVariants: nil,
            image: nil,
            primaryAction: action ?? CPAlertAction(
                title: String(localized: "carPlay.ok", bundle: .module),
                style: .cancel,
                handler: { _ in }
            ),
            secondaryAction: nil,
            duration: action == nil ? Self.alertDuration : 0
        )
        mapTemplate.present(navigationAlert: alert, animated: true)
    }
}

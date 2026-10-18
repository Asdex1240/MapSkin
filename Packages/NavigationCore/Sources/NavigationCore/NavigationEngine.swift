import Foundation
import Observation

@MainActor
@Observable
public final class NavigationEngine {
    public static let offRouteDistance = 50.0
    public static let offRouteDuration: TimeInterval = 5
    public static let maneuverAdvanceDistance = 20.0
    public static let arrivalDistance = 30.0

    public private(set) var status: NavigationStatus = .idle
    public private(set) var route: Route?
    public private(set) var progress: NavigationProgress?
    public private(set) var hasRerouteFailure = false

    private let routingProvider: any RoutingProvider
    private let locationTracker: any LocationTracking
    private var request: RouteRequest?
    private var measure = PolylineMeasure(coordinates: [])
    private var maneuverDistances: [Double] = []
    private var nextManeuverIndex = 0
    private var offRouteSince: Date?
    private var trackingTask: Task<Void, Never>?

    public init(routingProvider: any RoutingProvider, locationTracker: any LocationTracking) {
        self.routingProvider = routingProvider
        self.locationTracker = locationTracker
    }

    public func start(route: Route, request: RouteRequest) {
        stop()
        self.request = request
        activate(route, at: nil, now: .now)
        status = .navigating
        trackLocation()
    }

    public func stop() {
        trackingTask?.cancel()
        trackingTask = nil
        status = .idle
        route = nil
        progress = nil
        request = nil
        offRouteSince = nil
        hasRerouteFailure = false
    }

    func process(_ sample: LocationSample) async {
        guard status == .navigating else { return }
        let position = measure.position(of: sample.coordinate)
        if hasBeenOffRouteTooLong(position, at: sample.timestamp) {
            await reroute(from: sample)
            return
        }
        advanceManeuvers(to: position.distanceAlongLine)
        updateProgress(alongRoute: position.distanceAlongLine, sample: sample, now: sample.timestamp)
        if measure.totalLength - position.distanceAlongLine <= Self.arrivalDistance {
            arrive()
        }
    }

    private func trackLocation() {
        let samples = locationTracker.samples(for: .navigation)
        trackingTask = Task { [weak self] in
            for await sample in samples {
                await self?.process(sample)
            }
        }
    }

    private func activate(_ newRoute: Route, at sample: LocationSample?, now: Date) {
        route = newRoute
        measure = PolylineMeasure(coordinates: newRoute.polyline)
        maneuverDistances = newRoute.maneuvers.map { measure.position(of: $0.coordinate).distanceAlongLine }
        nextManeuverIndex = 0
        offRouteSince = nil
        let alongRoute = sample.map { measure.position(of: $0.coordinate).distanceAlongLine } ?? 0
        advanceManeuvers(to: alongRoute)
        updateProgress(alongRoute: alongRoute, sample: sample, now: now)
    }

    private func hasBeenOffRouteTooLong(_ position: PolylinePosition, at timestamp: Date) -> Bool {
        guard position.distanceFromLine > Self.offRouteDistance else {
            offRouteSince = nil
            return false
        }
        let since = offRouteSince ?? timestamp
        offRouteSince = since
        return timestamp.timeIntervalSince(since) > Self.offRouteDuration
    }

    private func reroute(from sample: LocationSample) async {
        guard let request else { return }
        status = .rerouting
        let newRequest = request.departing(from: sample.coordinate)
        do {
            let routes = try await routingProvider.routes(for: newRequest)
            guard status == .rerouting else { return }
            guard let newRoute = routes.first else { throw RoutingError.noRouteFound }
            self.request = newRequest
            hasRerouteFailure = false
            activate(newRoute, at: sample, now: sample.timestamp)
            status = .navigating
        } catch {
            guard status == .rerouting else { return }
            hasRerouteFailure = true
            offRouteSince = nil
            status = .navigating
        }
    }

    private func advanceManeuvers(to alongRoute: Double) {
        while nextManeuverIndex < maneuverDistances.count - 1,
              maneuverDistances[nextManeuverIndex] - alongRoute <= Self.maneuverAdvanceDistance {
            nextManeuverIndex += 1
        }
    }

    private func updateProgress(alongRoute: Double, sample: LocationSample?, now: Date) {
        guard let route else { return }
        let remaining = max(0, measure.totalLength - alongRoute)
        let nextDistance = maneuverDistances.indices.contains(nextManeuverIndex)
            ? max(0, maneuverDistances[nextManeuverIndex] - alongRoute)
            : remaining
        let remainingTime = remainingTravelTime(for: route, remainingDistance: remaining)
        progress = NavigationProgress(
            nextManeuver: maneuver(at: nextManeuverIndex, in: route),
            followingManeuver: maneuver(at: nextManeuverIndex + 1, in: route),
            distanceToNextManeuver: Measurement(value: nextDistance, unit: .meters),
            remainingDistance: Measurement(value: remaining, unit: .meters),
            remainingTravelTime: remainingTime,
            estimatedArrival: now.addingTimeInterval(remainingTime.timeInterval),
            location: sample
        )
    }

    private func maneuver(at index: Int, in route: Route) -> Maneuver? {
        route.maneuvers.indices.contains(index) ? route.maneuvers[index] : nil
    }

    private func remainingTravelTime(for route: Route, remainingDistance: Double) -> Duration {
        guard measure.totalLength > 0 else { return .zero }
        return route.expectedTravelTime * (remainingDistance / measure.totalLength)
    }

    private func arrive() {
        trackingTask?.cancel()
        trackingTask = nil
        status = .arrived
    }
}

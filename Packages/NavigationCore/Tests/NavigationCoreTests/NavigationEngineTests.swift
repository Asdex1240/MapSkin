import Foundation
import Testing
@testable import NavigationCore

@MainActor
struct NavigationEngineTests {
    private let rerouted = Route(
        id: "rerouted",
        name: "Rerouted",
        polyline: [TestRoutes.point(north: 300, east: 80), TestRoutes.point(north: 1000)],
        maneuvers: [Maneuver(id: 0, kind: .arrive, instruction: "Arrive", coordinate: TestRoutes.point(north: 1000))],
        distance: Measurement(value: 710, unit: .meters),
        expectedTravelTime: .seconds(70)
    )

    @Test func startsWithFirstUpcomingManeuver() {
        let engine = makeEngine()

        engine.start(route: TestRoutes.northbound, request: TestRoutes.request)

        #expect(engine.status == .navigating)
        #expect(engine.progress?.nextManeuver?.id == 1)
        #expect(engine.progress?.followingManeuver?.id == 2)
    }

    @Test func reportsDistanceToNextManeuver() async throws {
        let engine = makeEngine()
        engine.start(route: TestRoutes.northbound, request: TestRoutes.request)

        await engine.process(TestRoutes.sample(north: 200))

        let distance = try #require(engine.progress?.distanceToNextManeuver.converted(to: .meters).value)
        #expect(abs(distance - 300) < 1)
    }

    @Test func advancesToNextManeuverWhenReachingIt() async {
        let engine = makeEngine()
        engine.start(route: TestRoutes.northbound, request: TestRoutes.request)

        await engine.process(TestRoutes.sample(north: 490))

        #expect(engine.progress?.nextManeuver?.id == 2)
        #expect(engine.progress?.followingManeuver == nil)
    }

    @Test func keepsCurrentManeuverWhileStillApproaching() async {
        let engine = makeEngine()
        engine.start(route: TestRoutes.northbound, request: TestRoutes.request)

        await engine.process(TestRoutes.sample(north: 450))

        #expect(engine.progress?.nextManeuver?.id == 1)
    }

    @Test func estimatesRemainingTimeProportionally() async throws {
        let engine = makeEngine()
        engine.start(route: TestRoutes.northbound, request: TestRoutes.request)

        await engine.process(TestRoutes.sample(north: 500))

        let progress = try #require(engine.progress)
        #expect(abs(progress.remainingTravelTime.timeInterval - 50) < 0.5)
        #expect(abs(progress.estimatedArrival.timeIntervalSince(TestRoutes.startDate) - 50) < 0.5)
    }

    @Test func recalculatesAfterFiveSecondsOffRoute() async {
        let routing = RoutingProviderSpy(result: .success([rerouted]))
        let engine = makeEngine(routing: routing)
        engine.start(route: TestRoutes.northbound, request: TestRoutes.request)

        await engine.process(TestRoutes.sample(north: 300, east: 80, after: 0))
        await engine.process(TestRoutes.sample(north: 300, east: 80, after: 3))
        await engine.process(TestRoutes.sample(north: 300, east: 80, after: 6))

        let requests = await routing.requests
        #expect(requests == [TestRoutes.request.departing(from: TestRoutes.point(north: 300, east: 80))])
        #expect(engine.route?.id == "rerouted")
        #expect(engine.status == .navigating)
    }

    @Test func doesNotRecalculateBeforeFiveSecondsOffRoute() async {
        let routing = RoutingProviderSpy(result: .success([rerouted]))
        let engine = makeEngine(routing: routing)
        engine.start(route: TestRoutes.northbound, request: TestRoutes.request)

        await engine.process(TestRoutes.sample(north: 300, east: 80, after: 0))
        await engine.process(TestRoutes.sample(north: 300, east: 80, after: 4.5))

        #expect(await routing.requests.isEmpty)
    }

    @Test func resetsOffRouteTimerWhenBackOnRoute() async {
        let routing = RoutingProviderSpy(result: .success([rerouted]))
        let engine = makeEngine(routing: routing)
        engine.start(route: TestRoutes.northbound, request: TestRoutes.request)

        await engine.process(TestRoutes.sample(north: 300, east: 80, after: 0))
        await engine.process(TestRoutes.sample(north: 320, after: 4))
        await engine.process(TestRoutes.sample(north: 340, east: 80, after: 6))
        await engine.process(TestRoutes.sample(north: 360, east: 80, after: 9))

        #expect(await routing.requests.isEmpty)
    }

    @Test func toleratesDeviationsUpToFiftyMeters() async {
        let routing = RoutingProviderSpy(result: .success([rerouted]))
        let engine = makeEngine(routing: routing)
        engine.start(route: TestRoutes.northbound, request: TestRoutes.request)

        for second in stride(from: 0.0, through: 20, by: 2) {
            await engine.process(TestRoutes.sample(north: 300, east: 45, after: second))
        }

        #expect(await routing.requests.isEmpty)
        #expect(engine.route?.id == "northbound")
    }

    @Test func keepsNavigatingWhenRerouteFails() async {
        let engine = makeEngine(routing: RoutingProviderSpy(result: .failure(.serviceUnavailable)))
        engine.start(route: TestRoutes.northbound, request: TestRoutes.request)

        await engine.process(TestRoutes.sample(north: 300, east: 80, after: 0))
        await engine.process(TestRoutes.sample(north: 300, east: 80, after: 6))

        #expect(engine.status == .navigating)
        #expect(engine.hasRerouteFailure)
        #expect(engine.route?.id == "northbound")
    }

    @Test func arrivesNearDestination() async {
        let engine = makeEngine()
        engine.start(route: TestRoutes.northbound, request: TestRoutes.request)

        await engine.process(TestRoutes.sample(north: 980))

        #expect(engine.status == .arrived)
    }

    @Test func ignoresSamplesAfterArrival() async {
        let routing = RoutingProviderSpy(result: .success([rerouted]))
        let engine = makeEngine(routing: routing)
        engine.start(route: TestRoutes.northbound, request: TestRoutes.request)
        await engine.process(TestRoutes.sample(north: 990))

        await engine.process(TestRoutes.sample(north: 990, east: 200, after: 0))
        await engine.process(TestRoutes.sample(north: 990, east: 200, after: 10))

        #expect(engine.status == .arrived)
        #expect(await routing.requests.isEmpty)
    }

    @Test func stopClearsNavigation() {
        let engine = makeEngine()
        engine.start(route: TestRoutes.northbound, request: TestRoutes.request)

        engine.stop()

        #expect(engine.status == .idle)
        #expect(engine.route == nil)
        #expect(engine.progress == nil)
    }

    private func makeEngine(
        routing: RoutingProviderSpy = RoutingProviderSpy(result: .success([]))
    ) -> NavigationEngine {
        NavigationEngine(routingProvider: routing, locationTracker: SilentLocationTracker())
    }
}

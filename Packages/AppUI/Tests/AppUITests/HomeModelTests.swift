import MapRendering
import NavigationCore
import Testing
@testable import AppUI

@MainActor
struct HomeModelTests {
    private let fastest = HomeModelFixture.route(id: "fastest")
    private let scenic = HomeModelFixture.route(id: "scenic")

    @Test func plansRoutesFromCurrentLocation() async throws {
        let fixture = try HomeModelFixture(routes: .success([fastest, scenic]))
        defer { fixture.tearDown() }

        await fixture.model.planRoute(to: HomeModelFixture.destination)

        guard case .ready(let plan) = fixture.model.planning else {
            Issue.record("Expected a ready plan, got \(String(describing: fixture.model.planning))")
            return
        }
        #expect(plan.routes.map(\.id) == ["fastest", "scenic"])
        #expect(plan.selectedRoute?.id == "fastest")
        #expect(plan.request.origin == HomeModelFixture.userLocation)
        #expect(fixture.model.cameraMode == .routeOverview)
    }

    @Test func remembersPlannedDestination() async throws {
        let fixture = try HomeModelFixture(routes: .success([fastest]))
        defer { fixture.tearDown() }

        await fixture.model.planRoute(to: HomeModelFixture.destination)

        #expect(fixture.model.recentPlaces.places.first == HomeModelFixture.destination)
    }

    @Test func reportsMissingLocation() async throws {
        let fixture = try HomeModelFixture(routes: .success([fastest]), location: nil)
        defer { fixture.tearDown() }

        await fixture.model.planRoute(to: HomeModelFixture.destination)

        guard case .failed(_, let message) = fixture.model.planning else {
            Issue.record("Expected a failed plan")
            return
        }
        #expect(!message.isEmpty)
    }

    @Test func reportsRoutingFailure() async throws {
        let fixture = try HomeModelFixture(routes: .failure(.noRouteFound))
        defer { fixture.tearDown() }

        await fixture.model.planRoute(to: HomeModelFixture.destination)

        #expect(fixture.model.planning == .failed(
            HomeModelFixture.destination,
            message: RoutingError.noRouteFound.localizedDescription
        ))
    }

    @Test func showsAllPlannedRoutesOnTheMap() async throws {
        let fixture = try HomeModelFixture(routes: .success([fastest, scenic]))
        defer { fixture.tearDown() }

        await fixture.model.planRoute(to: HomeModelFixture.destination)
        fixture.model.selectRoute("scenic")

        let overlay = fixture.model.routeOverlay
        #expect(overlay.routes.count == 2)
        #expect(overlay.selectedRouteID == "scenic")
        #expect(overlay.destination == HomeModelFixture.destination.coordinate)
    }

    @Test func startsNavigationWithSelectedRoute() async throws {
        let fixture = try HomeModelFixture(routes: .success([fastest, scenic]))
        defer { fixture.tearDown() }
        await fixture.model.planRoute(to: HomeModelFixture.destination)
        fixture.model.selectRoute("scenic")

        fixture.model.startNavigation()

        #expect(fixture.navigation.route?.id == "scenic")
        #expect(fixture.model.isNavigating)
        #expect(fixture.model.cameraMode == .navigation)
    }

    @Test func endingNavigationReturnsToBrowsing() async throws {
        let fixture = try HomeModelFixture(routes: .success([fastest]))
        defer { fixture.tearDown() }
        await fixture.model.planRoute(to: HomeModelFixture.destination)
        fixture.model.startNavigation()

        fixture.model.endNavigation()

        #expect(!fixture.model.isNavigating)
        #expect(fixture.model.planning == nil)
        #expect(fixture.model.cameraMode == .followingUser)
        #expect(fixture.model.routeOverlay == .empty)
    }

    @Test func cancelingPlanClearsTheMap() async throws {
        let fixture = try HomeModelFixture(routes: .success([fastest]))
        defer { fixture.tearDown() }
        await fixture.model.planRoute(to: HomeModelFixture.destination)

        fixture.model.cancelPlanning()

        #expect(fixture.model.routeOverlay == .empty)
        #expect(fixture.model.cameraMode == .followingUser)
    }

    @Test func measuresDistanceFromUser() async throws {
        let fixture = try HomeModelFixture(routes: .success([fastest]))
        defer { fixture.tearDown() }
        await fixture.model.prepare()

        let distance = try #require(fixture.model.distance(to: HomeModelFixture.destination))

        #expect(distance.converted(to: .kilometers).value > 2)
        #expect(distance.converted(to: .kilometers).value < 3)
    }
}

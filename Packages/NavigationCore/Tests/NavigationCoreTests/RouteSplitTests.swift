import Foundation
import NavigationCore
import Testing

struct RouteSplitTests {
    private let route = TestRoutes.northbound

    @Test func splitsAtTraveledDistance() {
        let split = route.split(atDistance: Measurement(value: 375, unit: .meters))

        let splitPoint = TestRoutes.point(north: 375)
        #expect(split.traveled.count == 3)
        #expect(split.remaining.count == 4)
        #expect(split.traveled.last.map { $0.distance(to: splitPoint) < 0.5 } == true)
        #expect(split.traveled.last == split.remaining.first)
    }

    @Test func keepsWholeRouteRemainingBeforeStarting() {
        let split = route.split(atDistance: Measurement(value: 0, unit: .meters))

        #expect(split.traveled.isEmpty)
        #expect(split.remaining == route.polyline)
    }

    @Test func marksWholeRouteTraveledAtTheEnd() {
        let split = route.split(atDistance: Measurement(value: 5, unit: .kilometers))

        #expect(split.traveled == route.polyline)
        #expect(split.remaining.isEmpty)
    }

    @Test func splitsExactlyOnAVertex() {
        let split = route.split(atDistance: Measurement(value: 500, unit: .meters))

        #expect(split.remaining.first.map { $0.distance(to: TestRoutes.point(north: 500)) < 0.5 } == true)
    }
}

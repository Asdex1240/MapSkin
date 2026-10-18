import Testing
@testable import NavigationCore

struct PolylineMeasureTests {
    private let measure = PolylineMeasure(coordinates: TestRoutes.northbound.polyline)

    @Test func measuresTotalLength() {
        #expect(abs(measure.totalLength - 1000) < 0.5)
    }

    @Test func locatesPointOnTheLine() {
        let position = measure.position(of: TestRoutes.point(north: 620))

        #expect(position.distanceFromLine < 0.5)
        #expect(abs(position.distanceAlongLine - 620) < 0.5)
    }

    @Test func measuresSidewaysDistanceFromTheLine() {
        let position = measure.position(of: TestRoutes.point(north: 300, east: 40))

        #expect(abs(position.distanceFromLine - 40) < 0.5)
        #expect(abs(position.distanceAlongLine - 300) < 0.5)
    }

    @Test func clampsPointsBeyondTheEnd() {
        let position = measure.position(of: TestRoutes.point(north: 1100))

        #expect(abs(position.distanceAlongLine - 1000) < 0.5)
        #expect(abs(position.distanceFromLine - 100) < 0.5)
    }
}

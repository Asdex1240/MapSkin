import NavigationCore
import Testing

struct ManeuverKindGeometryTests {
    private let northbound = [TestRoutes.point(north: 0), TestRoutes.point(north: 100)]

    @Test func detectsRightTurn() {
        let eastbound = [TestRoutes.point(north: 100), TestRoutes.point(north: 100, east: 100)]

        #expect(ManeuverKind(arrivingAlong: northbound, leavingAlong: eastbound) == .turnRight)
    }

    @Test func detectsLeftTurn() {
        let westbound = [TestRoutes.point(north: 100), TestRoutes.point(north: 100, east: -100)]

        #expect(ManeuverKind(arrivingAlong: northbound, leavingAlong: westbound) == .turnLeft)
    }

    @Test func detectsSlightRight() {
        let northeast = [TestRoutes.point(north: 100), TestRoutes.point(north: 200, east: 50)]

        #expect(ManeuverKind(arrivingAlong: northbound, leavingAlong: northeast) == .turnSlightRight)
    }

    @Test func ignoresTinySegmentsWhenMeasuringBearings() {
        let eastboundWithJitter = [
            TestRoutes.point(north: 100),
            TestRoutes.point(north: 101),
            TestRoutes.point(north: 100, east: 100)
        ]

        #expect(ManeuverKind(arrivingAlong: northbound, leavingAlong: eastboundWithJitter) == .turnRight)
    }

    @Test func fallsBackToStraightWithoutGeometry() {
        #expect(ManeuverKind(arrivingAlong: [], leavingAlong: northbound) == .continueStraight)
    }
}

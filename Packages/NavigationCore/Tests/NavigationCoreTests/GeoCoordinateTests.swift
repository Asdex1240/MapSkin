import NavigationCore
import Testing

struct GeoCoordinateTests {
    @Test func measuresDistanceAlongMeridian() {
        let start = GeoCoordinate(latitude: 25, longitude: -100)
        let end = GeoCoordinate(latitude: 26, longitude: -100)

        #expect(abs(start.distance(to: end) - GeoCoordinate.metersPerDegreeLatitude) < 1)
    }

    @Test func distanceToItselfIsZero() {
        #expect(TestRoutes.origin.distance(to: TestRoutes.origin) == 0)
    }

    @Test func bearingPointsNorthAndEast() {
        let origin = TestRoutes.origin

        #expect(abs(origin.bearing(to: TestRoutes.point(north: 100))) < 0.01)
        #expect(abs(origin.bearing(to: TestRoutes.point(north: 0, east: 100)) - 90) < 0.01)
    }

    @Test func bearingIsNeverNegative() {
        let origin = TestRoutes.origin

        let westward = origin.bearing(to: TestRoutes.point(north: 0, east: -100))

        #expect(abs(westward - 270) < 0.01)
    }
}

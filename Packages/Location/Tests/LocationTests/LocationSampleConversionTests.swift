import CoreLocation
import Testing
@testable import Location
import NavigationCore

struct LocationSampleConversionTests {
    @Test func keepsCoordinateCourseAndSpeed() {
        let location = makeLocation(course: 90, speed: 12)

        let sample = LocationSample(location)

        #expect(sample.coordinate == GeoCoordinate(latitude: 25.67, longitude: -100.31))
        #expect(sample.course == 90)
        #expect(sample.speed == 12)
        #expect(sample.horizontalAccuracy == 5)
    }

    @Test func dropsInvalidCourseAndSpeed() {
        let location = makeLocation(course: -1, speed: -1)

        let sample = LocationSample(location)

        #expect(sample.course == nil)
        #expect(sample.speed == nil)
    }

    @Test func usesHighAccuracyOnlyWhileNavigating() {
        #expect(LocationTrackingMode.navigation.keepsRunningInBackground)
        #expect(!LocationTrackingMode.standard.keepsRunningInBackground)
    }

    private func makeLocation(course: Double, speed: Double) -> CLLocation {
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 25.67, longitude: -100.31),
            altitude: 540,
            horizontalAccuracy: 5,
            verticalAccuracy: 5,
            course: course,
            speed: speed,
            timestamp: Date(timeIntervalSince1970: 1_800_000_000)
        )
    }
}

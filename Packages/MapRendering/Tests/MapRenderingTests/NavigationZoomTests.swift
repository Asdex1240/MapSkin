import Testing
@testable import MapRendering

struct NavigationZoomTests {
    @Test(arguments: [
        (nil, 17.0),
        (5.0, 17.0),
        (12.0, 16.0),
        (20.0, 15.5),
        (33.0, 15.0)
    ] as [(Double?, Double)])
    func zoomsOutAsSpeedIncreases(speed: Double?, expectedZoom: Double) {
        #expect(NavigationZoom.level(forSpeed: speed) == expectedZoom)
    }

    @Test func tiltsCameraDuringNavigation() {
        #expect(NavigationZoom.pitch == 45)
    }
}

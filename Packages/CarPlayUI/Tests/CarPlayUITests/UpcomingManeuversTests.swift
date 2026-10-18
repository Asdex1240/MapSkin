import NavigationCore
import Testing
@testable import CarPlayUI

struct UpcomingManeuversTests {
    private let origin = GeoCoordinate(latitude: 25.67, longitude: -100.31)

    @Test func showsFollowingManeuverWhenItComesRightAfter() {
        let next = maneuver(id: 1, north: 0)
        let following = maneuver(id: 2, north: 150)

        #expect(UpcomingManeuvers.visible(next: next, following: following).map(\.id) == [1, 2])
    }

    @Test func hidesFollowingManeuverWhenItIsFarAway() {
        let next = maneuver(id: 1, north: 0)
        let following = maneuver(id: 2, north: 1_200)

        #expect(UpcomingManeuvers.visible(next: next, following: following).map(\.id) == [1])
    }

    @Test func showsOnlyNextManeuverWhenThereIsNoFollowingOne() {
        #expect(UpcomingManeuvers.visible(next: maneuver(id: 1, north: 0), following: nil).map(\.id) == [1])
    }

    @Test func showsNothingWithoutManeuvers() {
        #expect(UpcomingManeuvers.visible(next: nil, following: nil).isEmpty)
    }

    private func maneuver(id: Int, north meters: Double) -> Maneuver {
        let coordinate = GeoCoordinate(latitude: origin.latitude + meters / 111_195, longitude: origin.longitude)
        return Maneuver(id: id, kind: .turnLeft, instruction: "Turn left", coordinate: coordinate)
    }
}

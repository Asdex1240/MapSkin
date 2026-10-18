import NavigationCore

enum UpcomingManeuvers {
    static let closeFollowUpDistance = 400.0

    static func visible(next: Maneuver?, following: Maneuver?) -> [Maneuver] {
        guard let next else { return [] }
        guard
            let following,
            next.coordinate.distance(to: following.coordinate) <= closeFollowUpDistance
        else { return [next] }
        return [next, following]
    }
}

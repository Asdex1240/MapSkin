import Foundation

public struct NavigationProgress: Equatable, Sendable {
    public let nextManeuver: Maneuver?
    public let followingManeuver: Maneuver?
    public let distanceToNextManeuver: Measurement<UnitLength>
    public let remainingDistance: Measurement<UnitLength>
    public let distanceTraveled: Measurement<UnitLength>
    public let remainingTravelTime: Duration
    public let estimatedArrival: Date
    public let location: LocationSample?

    public init(
        nextManeuver: Maneuver?,
        followingManeuver: Maneuver?,
        distanceToNextManeuver: Measurement<UnitLength>,
        remainingDistance: Measurement<UnitLength>,
        distanceTraveled: Measurement<UnitLength>,
        remainingTravelTime: Duration,
        estimatedArrival: Date,
        location: LocationSample?
    ) {
        self.nextManeuver = nextManeuver
        self.followingManeuver = followingManeuver
        self.distanceToNextManeuver = distanceToNextManeuver
        self.remainingDistance = remainingDistance
        self.distanceTraveled = distanceTraveled
        self.remainingTravelTime = remainingTravelTime
        self.estimatedArrival = estimatedArrival
        self.location = location
    }
}

extension ManeuverKind {
    private static let minimumSegmentLength = 3.0

    public init(arrivingAlong incoming: [GeoCoordinate], leavingAlong outgoing: [GeoCoordinate]) {
        guard
            let incomingBearing = Self.finalBearing(of: incoming),
            let outgoingBearing = Self.initialBearing(of: outgoing)
        else {
            self = .continueStraight
            return
        }
        self.init(turnAngle: Self.turnAngle(fromBearing: incomingBearing, toBearing: outgoingBearing))
    }

    private static func initialBearing(of path: [GeoCoordinate]) -> Double? {
        guard
            let start = path.first,
            let next = path.dropFirst().first(where: { start.distance(to: $0) >= minimumSegmentLength })
        else { return nil }
        return start.bearing(to: next)
    }

    private static func finalBearing(of path: [GeoCoordinate]) -> Double? {
        guard
            let end = path.last,
            let previous = path.dropLast().last(where: { $0.distance(to: end) >= minimumSegmentLength })
        else { return nil }
        return previous.bearing(to: end)
    }
}

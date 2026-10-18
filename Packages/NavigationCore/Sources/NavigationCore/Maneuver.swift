public struct Maneuver: Identifiable, Equatable, Sendable {
    public let id: Int
    public let kind: ManeuverKind
    public let instruction: String
    public let coordinate: GeoCoordinate

    public init(id: Int, kind: ManeuverKind, instruction: String, coordinate: GeoCoordinate) {
        self.id = id
        self.kind = kind
        self.instruction = instruction
        self.coordinate = coordinate
    }
}

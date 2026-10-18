public enum ManeuverKind: String, Codable, Sendable {
    case depart
    case continueStraight
    case turnSlightLeft
    case turnLeft
    case turnSharpLeft
    case turnSlightRight
    case turnRight
    case turnSharpRight
    case uTurn
    case arrive

    public init(turnAngle: Double) {
        let magnitude = abs(turnAngle)
        let isRight = turnAngle > 0
        switch magnitude {
        case ..<20: self = .continueStraight
        case ..<45: self = isRight ? .turnSlightRight : .turnSlightLeft
        case ..<135: self = isRight ? .turnRight : .turnLeft
        case ..<170: self = isRight ? .turnSharpRight : .turnSharpLeft
        default: self = .uTurn
        }
    }

    public static func turnAngle(fromBearing incoming: Double, toBearing outgoing: Double) -> Double {
        let difference = (outgoing - incoming).truncatingRemainder(dividingBy: 360)
        if difference > 180 { return difference - 360 }
        if difference < -180 { return difference + 360 }
        return difference
    }
}

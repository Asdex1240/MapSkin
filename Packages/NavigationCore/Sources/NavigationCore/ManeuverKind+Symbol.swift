extension ManeuverKind {
    public var symbolName: String {
        switch self {
        case .depart: "location.north.fill"
        case .continueStraight: "arrow.up"
        case .turnSlightLeft: "arrow.up.left"
        case .turnLeft: "arrow.turn.up.left"
        case .turnSharpLeft: "arrow.down.left"
        case .turnSlightRight: "arrow.up.right"
        case .turnRight: "arrow.turn.up.right"
        case .turnSharpRight: "arrow.down.right"
        case .uTurn: "arrow.uturn.down"
        case .arrive: "mappin.circle.fill"
        }
    }
}

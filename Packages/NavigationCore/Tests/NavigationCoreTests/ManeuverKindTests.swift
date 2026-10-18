import NavigationCore
import Testing

struct ManeuverKindTests {
    @Test(arguments: [
        (0.0, ManeuverKind.continueStraight),
        (-15, .continueStraight),
        (30, .turnSlightRight),
        (-30, .turnSlightLeft),
        (90, .turnRight),
        (-90, .turnLeft),
        (150, .turnSharpRight),
        (-150, .turnSharpLeft),
        (178, .uTurn),
        (-178, .uTurn)
    ])
    func classifiesTurnAngle(angle: Double, expected: ManeuverKind) {
        #expect(ManeuverKind(turnAngle: angle) == expected)
    }

    @Test func turnAngleWrapsAroundNorth() {
        #expect(ManeuverKind.turnAngle(fromBearing: 350, toBearing: 10) == 20)
        #expect(ManeuverKind.turnAngle(fromBearing: 10, toBearing: 350) == -20)
    }

    @Test func turnAngleIsPositiveForRightTurns() {
        #expect(ManeuverKind.turnAngle(fromBearing: 0, toBearing: 90) == 90)
        #expect(ManeuverKind.turnAngle(fromBearing: 90, toBearing: 0) == -90)
    }
}

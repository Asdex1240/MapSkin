import CarPlay
import Foundation
import NavigationCore
import Testing
@testable import CarPlayUI

@MainActor
struct CarPlayTemplateFactoryTests {
    private let origin = GeoCoordinate(latitude: 25.6714, longitude: -100.3090)
    private let destination = GeoCoordinate(latitude: 25.6785, longitude: -100.2840)

    @Test func createsOneRouteChoicePerRoute() {
        let routes = [makeRoute(id: "fast"), makeRoute(id: "scenic")]

        let trip = CarPlayTemplateFactory.trip(
            for: routes,
            request: RouteRequest(origin: origin, destination: destination),
            destinationName: "Parque Fundidora"
        )

        #expect(trip.routeChoices.count == 2)
        #expect(trip.destination.name == "Parque Fundidora")
        #expect(trip.routeChoices.compactMap(CarPlayTemplateFactory.routeID(of:)) == ["fast", "scenic"])
    }

    @Test func describesRouteChoiceWithDistanceAndDuration() {
        let choice = CarPlayTemplateFactory.routeChoice(for: makeRoute(id: "fast"))

        #expect(!choice.summaryVariants.isEmpty)
        #expect(choice.additionalInformationVariants?.isEmpty == false)
        #expect(choice.selectionSummaryVariants?.isEmpty == false)
    }

    @Test func buildsManeuverWithInstructionSymbolAndEstimates() {
        let maneuver = Maneuver(id: 4, kind: .turnLeft, instruction: "Turn left onto Constitución", coordinate: origin)

        let carPlayManeuver = CarPlayTemplateFactory.maneuver(
            for: maneuver,
            distance: Measurement(value: 280, unit: .meters),
            time: .seconds(40)
        )

        #expect(carPlayManeuver.instructionVariants == ["Turn left onto Constitución"])
        #expect(carPlayManeuver.symbolImage != nil)
        let distance = carPlayManeuver.initialTravelEstimates?.distanceRemaining.converted(to: .meters).value ?? 0
        #expect(abs(distance - 280) < 30)
        #expect(carPlayManeuver.initialTravelEstimates?.timeRemaining == 40)
        #expect(carPlayManeuver.userInfo as? Int == 4)
    }

    @Test func everyManeuverKindHasASymbol() {
        let kinds: [ManeuverKind] = [
            .depart, .continueStraight, .turnSlightLeft, .turnLeft, .turnSharpLeft,
            .turnSlightRight, .turnRight, .turnSharpRight, .uTurn, .arrive
        ]

        for kind in kinds {
            #expect(UIImage(systemName: kind.symbolName) != nil, "\(kind)")
        }
    }

    private func makeRoute(id: String) -> Route {
        Route(
            id: id,
            name: "Av. Constitución",
            polyline: [origin, destination],
            maneuvers: [],
            distance: Measurement(value: 2.6, unit: .kilometers),
            expectedTravelTime: .seconds(420)
        )
    }
}

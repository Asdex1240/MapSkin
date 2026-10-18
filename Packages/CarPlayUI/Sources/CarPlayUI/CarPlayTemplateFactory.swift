import CarPlay
import MapKit
import NavigationCore
import UIKit

@MainActor
enum CarPlayTemplateFactory {
    static let routeIDKey = "routeID"

    static func trip(for routes: [Route], request: RouteRequest, destinationName: String?) -> CPTrip {
        let choices = routes.map(routeChoice(for:))
        let destination = mapItem(at: request.destination, name: destinationName)
        let origin = mapItem(at: request.origin, name: nil)
        let trip = CPTrip(origin: origin, destination: destination, routeChoices: choices)
        trip.userInfo = [routeIDKey: routes.first?.id ?? ""]
        return trip
    }

    static func routeChoice(for route: Route) -> CPRouteChoice {
        let duration = CarPlayFormat.duration(route.expectedTravelTime)
        let distance = CarPlayFormat.distance(route.distance)
        let via = route.name.isEmpty ? distance : String(localized: "carPlay.route.via \(route.name)", bundle: .module)
        let choice = CPRouteChoice(
            summaryVariants: [via, distance],
            additionalInformationVariants: ["\(duration) · \(distance)", duration],
            selectionSummaryVariants: [via]
        )
        choice.userInfo = [routeIDKey: route.id]
        return choice
    }

    static func routeID(of choice: CPRouteChoice) -> Route.ID? {
        (choice.userInfo as? [String: String])?[routeIDKey]
    }

    static func maneuver(for maneuver: Maneuver, distance: Measurement<UnitLength>, time: Duration) -> CPManeuver {
        let carPlayManeuver = CPManeuver()
        carPlayManeuver.instructionVariants = [maneuver.instruction]
        carPlayManeuver.symbolImage = UIImage(systemName: maneuver.kind.symbolName)
        carPlayManeuver.initialTravelEstimates = travelEstimates(distance: distance, time: time)
        carPlayManeuver.userInfo = maneuver.id
        return carPlayManeuver
    }

    static func travelEstimates(distance: Measurement<UnitLength>, time: Duration) -> CPTravelEstimates {
        CPTravelEstimates(
            distanceRemaining: CarPlayFormat.displayDistance(distance),
            timeRemaining: TimeInterval(time.components.seconds)
        )
    }

    static func mapItem(at coordinate: GeoCoordinate, name: String?) -> MKMapItem {
        let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let item = MKMapItem(placemark: MKPlacemark(coordinate: location))
        item.name = name
        return item
    }

    static func previewTextConfiguration() -> CPTripPreviewTextConfiguration {
        CPTripPreviewTextConfiguration(
            startButtonTitle: String(localized: "carPlay.trip.start", bundle: .module),
            additionalRoutesButtonTitle: String(localized: "carPlay.trip.moreRoutes", bundle: .module),
            overviewButtonTitle: String(localized: "carPlay.trip.overview", bundle: .module)
        )
    }
}

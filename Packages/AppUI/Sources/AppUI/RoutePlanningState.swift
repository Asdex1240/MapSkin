import NavigationCore
import PlaceSearch

struct RoutePlan: Equatable {
    let place: Place
    let request: RouteRequest
    let routes: [Route]
    var selectedRouteID: Route.ID?

    var selectedRoute: Route? {
        routes.first { $0.id == selectedRouteID } ?? routes.first
    }
}

enum RoutePlanningState: Equatable {
    case loading(Place)
    case ready(RoutePlan)
    case failed(Place, message: String)

    var place: Place {
        switch self {
        case .loading(let place), .failed(let place, _): place
        case .ready(let plan): plan.place
        }
    }
}

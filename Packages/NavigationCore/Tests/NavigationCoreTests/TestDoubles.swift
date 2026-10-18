import NavigationCore

actor RoutingProviderSpy: RoutingProvider {
    private(set) var requests: [RouteRequest] = []
    private let result: Result<[Route], RoutingError>

    init(result: Result<[Route], RoutingError>) {
        self.result = result
    }

    func routes(for request: RouteRequest) async throws -> [Route] {
        requests.append(request)
        return try result.get()
    }
}

@MainActor
final class SilentLocationTracker: LocationTracking {
    func requestAuthorization() {}

    func samples(for mode: LocationTrackingMode) -> AsyncStream<LocationSample> {
        AsyncStream { _ in }
    }

    func currentSample() async -> LocationSample? {
        nil
    }
}

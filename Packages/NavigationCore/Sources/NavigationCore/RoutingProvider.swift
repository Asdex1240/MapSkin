public protocol RoutingProvider: Sendable {
    func routes(for request: RouteRequest) async throws -> [Route]
}

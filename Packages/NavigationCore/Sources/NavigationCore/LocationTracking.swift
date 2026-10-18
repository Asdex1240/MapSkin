public enum LocationTrackingMode: Sendable {
    case standard
    case navigation
}

@MainActor
public protocol LocationTracking: AnyObject {
    func requestAuthorization()
    func samples(for mode: LocationTrackingMode) -> AsyncStream<LocationSample>
    func currentSample() async -> LocationSample?
}

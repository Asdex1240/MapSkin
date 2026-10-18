import CoreLocation
import NavigationCore
import OSLog

@MainActor
public final class LocationService: LocationTracking {
    private static let cachedSampleMaximumAge: TimeInterval = 60
    private static let currentSampleTimeout = Duration.seconds(10)

    private let manager = CLLocationManager()
    private let logger = Logger(subsystem: "MapSkin", category: "LocationService")

    public init() {}

    public func requestAuthorization() {
        guard manager.authorizationStatus == .notDetermined else { return }
        manager.requestWhenInUseAuthorization()
    }

    public func samples(for mode: LocationTrackingMode) -> AsyncStream<LocationSample> {
        let logger = logger
        return AsyncStream { continuation in
            let task = Task { @MainActor in
                let backgroundSession = mode.keepsRunningInBackground ? CLBackgroundActivitySession() : nil
                defer { backgroundSession?.invalidate() }
                do {
                    for try await update in CLLocationUpdate.liveUpdates(mode.liveConfiguration) {
                        guard let location = update.location else { continue }
                        continuation.yield(LocationSample(location))
                    }
                } catch {
                    logger.error("Location updates stopped: \(error.localizedDescription)")
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    public func currentSample() async -> LocationSample? {
        if let cached = manager.location, -cached.timestamp.timeIntervalSinceNow < Self.cachedSampleMaximumAge {
            return LocationSample(cached)
        }
        let lookup = Task { await firstSample() }
        let timeout = Task {
            try await Task.sleep(for: Self.currentSampleTimeout)
            lookup.cancel()
        }
        let sample = await lookup.value
        timeout.cancel()
        return sample
    }

    private func firstSample() async -> LocationSample? {
        for await sample in samples(for: .standard) {
            return sample
        }
        return nil
    }
}

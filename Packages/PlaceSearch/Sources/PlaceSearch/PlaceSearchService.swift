import MapKit
import NavigationCore
import Observation
import OSLog

@MainActor
@Observable
public final class PlaceSearchService: NSObject {
    public private(set) var suggestions: [SearchSuggestion] = []

    @ObservationIgnored private let completer = MKLocalSearchCompleter()
    @ObservationIgnored private var completionsByID: [String: MKLocalSearchCompletion] = [:]
    @ObservationIgnored private var region: MKCoordinateRegion?
    @ObservationIgnored private let logger = Logger(subsystem: "MapSkin", category: "PlaceSearchService")

    override public init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    public func updateQuery(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completer.cancel()
            suggestions = []
            return
        }
        completer.queryFragment = trimmed
    }

    public func focus(on center: GeoCoordinate, radius: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude)
        let span = radius * 2
        let focusedRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: span, longitudinalMeters: span)
        region = focusedRegion
        completer.region = focusedRegion
    }

    public func place(for suggestion: SearchSuggestion) async throws -> Place {
        guard let completion = completionsByID[suggestion.id] else { throw PlaceSearchError.noResults }
        guard let place = try await search(MKLocalSearch.Request(completion: completion)).first else {
            throw PlaceSearchError.noResults
        }
        return place
    }

    public func places(matching query: String) async throws -> [Place] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        if let region {
            request.region = region
        }
        let places = try await search(request)
        guard !places.isEmpty else { throw PlaceSearchError.noResults }
        return places
    }

    private func search(_ request: MKLocalSearch.Request) async throws -> [Place] {
        do {
            return try await MKLocalSearch(request: request).start().mapItems.compactMap(Place.init)
        } catch let error as MKError where error.code == .placemarkNotFound {
            throw PlaceSearchError.noResults
        } catch {
            logger.error("Place search failed: \(error.localizedDescription)")
            throw PlaceSearchError.serviceUnavailable
        }
    }
}

extension PlaceSearchService: @preconcurrency MKLocalSearchCompleterDelegate {
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results
        completionsByID = Dictionary(
            results.map { (SearchSuggestion(title: $0.title, subtitle: $0.subtitle).id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        suggestions = results.map { SearchSuggestion(title: $0.title, subtitle: $0.subtitle) }
    }

    public func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        logger.error("Search suggestions failed: \(error.localizedDescription)")
        suggestions = []
    }
}

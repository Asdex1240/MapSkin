import Foundation

extension Route {
    public func split(atDistance distance: Measurement<UnitLength>) -> RouteSplit {
        let measure = PolylineMeasure(coordinates: polyline)
        guard polyline.count > 1 else { return RouteSplit(traveled: [], remaining: polyline) }
        let target = min(max(0, distance.converted(to: .meters).value), measure.totalLength)
        guard target > 0 else { return RouteSplit(traveled: [], remaining: polyline) }
        guard target < measure.totalLength else { return RouteSplit(traveled: polyline, remaining: []) }
        guard
            let endIndex = measure.cumulativeDistances.firstIndex(where: { $0 >= target }),
            endIndex > 0
        else { return RouteSplit(traveled: polyline, remaining: []) }
        let startDistance = measure.cumulativeDistances[endIndex - 1]
        let segmentLength = measure.cumulativeDistances[endIndex] - startDistance
        let fraction = segmentLength == 0 ? 0 : (target - startDistance) / segmentLength
        let splitPoint = polyline[endIndex - 1].interpolated(toward: polyline[endIndex], fraction: fraction)
        return RouteSplit(
            traveled: Array(polyline[..<endIndex]) + [splitPoint],
            remaining: [splitPoint] + Array(polyline[endIndex...])
        )
    }
}

public struct RouteSplit: Equatable, Sendable {
    public let traveled: [GeoCoordinate]
    public let remaining: [GeoCoordinate]
}

extension GeoCoordinate {
    func interpolated(toward other: GeoCoordinate, fraction: Double) -> GeoCoordinate {
        GeoCoordinate(
            latitude: latitude + (other.latitude - latitude) * fraction,
            longitude: longitude + (other.longitude - longitude) * fraction
        )
    }
}

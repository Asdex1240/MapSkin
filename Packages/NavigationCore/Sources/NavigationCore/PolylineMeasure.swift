import Foundation

struct PolylinePosition: Equatable {
    let distanceFromLine: Double
    let distanceAlongLine: Double
}

struct PolylineMeasure {
    private static let unknownPosition = PolylinePosition(distanceFromLine: .infinity, distanceAlongLine: 0)

    let coordinates: [GeoCoordinate]
    let cumulativeDistances: [Double]

    init(coordinates: [GeoCoordinate]) {
        self.coordinates = coordinates
        var distances = [0.0]
        for (start, end) in zip(coordinates, coordinates.dropFirst()) {
            distances.append((distances.last ?? 0) + start.distance(to: end))
        }
        cumulativeDistances = distances
    }

    var totalLength: Double {
        cumulativeDistances.last ?? 0
    }

    func position(of point: GeoCoordinate) -> PolylinePosition {
        guard let first = coordinates.first else { return Self.unknownPosition }
        guard coordinates.count > 1 else {
            return PolylinePosition(distanceFromLine: first.distance(to: point), distanceAlongLine: 0)
        }
        return coordinates.indices.dropLast()
            .map { position(of: point, onSegmentStartingAt: $0) }
            .min { $0.distanceFromLine < $1.distanceFromLine } ?? Self.unknownPosition
    }

    private func position(of point: GeoCoordinate, onSegmentStartingAt index: Int) -> PolylinePosition {
        let start = coordinates[index]
        let end = coordinates[index + 1]
        let plane = LocalPlane(origin: start)
        let segment = plane.project(end)
        let target = plane.project(point)
        let lengthSquared = segment.x * segment.x + segment.y * segment.y
        let projectedLength = target.x * segment.x + target.y * segment.y
        let fraction = lengthSquared == 0 ? 0 : min(1, max(0, projectedLength / lengthSquared))
        let closestX = segment.x * fraction
        let closestY = segment.y * fraction
        let distanceFromLine = hypot(target.x - closestX, target.y - closestY)
        let segmentLength = cumulativeDistances[index + 1] - cumulativeDistances[index]
        return PolylinePosition(
            distanceFromLine: distanceFromLine,
            distanceAlongLine: cumulativeDistances[index] + segmentLength * fraction
        )
    }
}

private struct LocalPlane {
    let origin: GeoCoordinate

    func project(_ coordinate: GeoCoordinate) -> (x: Double, y: Double) {
        let longitudeScale = cos(origin.latitude.radians) * GeoCoordinate.earthRadius
        let x = (coordinate.longitude - origin.longitude).radians * longitudeScale
        let y = (coordinate.latitude - origin.latitude).radians * GeoCoordinate.earthRadius
        return (x, y)
    }
}

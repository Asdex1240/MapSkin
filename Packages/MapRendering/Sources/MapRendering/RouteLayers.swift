import MapLibre
import MapStyle
import NavigationCore
import UIKit

@MainActor
enum RouteLayers {
    private static let routeSourceID = "route-source"
    private static let destinationSourceID = "destination-source"
    private static let selectedAttribute = "selected"

    static func apply(_ overlay: RouteOverlay, palette: MapPalette, to style: MLNStyle) {
        let routeShape = MLNShapeCollectionFeature(shapes: routeFeatures(for: overlay))
        let destinationShape = MLNShapeCollectionFeature(shapes: destinationFeatures(for: overlay))
        if let routeSource = style.source(withIdentifier: routeSourceID) as? MLNShapeSource,
           let destinationSource = style.source(withIdentifier: destinationSourceID) as? MLNShapeSource {
            routeSource.shape = routeShape
            destinationSource.shape = destinationShape
            return
        }
        install(routeShape: routeShape, destinationShape: destinationShape, palette: palette, in: style)
    }

    private static func install(
        routeShape: MLNShape,
        destinationShape: MLNShape,
        palette: MapPalette,
        in style: MLNStyle
    ) {
        let routeSource = MLNShapeSource(identifier: routeSourceID, shape: routeShape)
        let destinationSource = MLNShapeSource(identifier: destinationSourceID, shape: destinationShape)
        style.addSource(routeSource)
        style.addSource(destinationSource)
        let layers = [
            line(id: "route-alternative-casing", source: routeSource, isSelected: false,
                 color: palette.alternativeRouteCasing, widths: [10: 6, 14: 10, 18: 22]),
            line(id: "route-alternative", source: routeSource, isSelected: false,
                 color: palette.alternativeRoute, widths: [10: 4, 14: 7, 18: 16]),
            line(id: "route-selected-casing", source: routeSource, isSelected: true,
                 color: palette.routeCasing, widths: [10: 7, 14: 12, 18: 26]),
            line(id: "route-selected", source: routeSource, isSelected: true,
                 color: palette.route, widths: [10: 5, 14: 8, 18: 19]),
            destinationMarker(source: destinationSource, palette: palette)
        ]
        let firstLabel = style.layers.first { $0 is MLNSymbolStyleLayer }
        for layer in layers {
            if let firstLabel {
                style.insertLayer(layer, below: firstLabel)
            } else {
                style.addLayer(layer)
            }
        }
    }

    private static func routeFeatures(for overlay: RouteOverlay) -> [MLNShape] {
        let selectedID = overlay.selectedRoute?.id
        let ordered = overlay.routes.filter { $0.id != selectedID } + overlay.routes.filter { $0.id == selectedID }
        return ordered.map { route in
            var coordinates = route.polyline.map(\.locationCoordinate)
            let feature = MLNPolylineFeature(coordinates: &coordinates, count: UInt(coordinates.count))
            feature.attributes = [selectedAttribute: route.id == selectedID]
            return feature
        }
    }

    private static func destinationFeatures(for overlay: RouteOverlay) -> [MLNShape] {
        guard let destination = overlay.destination else { return [] }
        let feature = MLNPointFeature()
        feature.coordinate = destination.locationCoordinate
        return [feature]
    }

    private static func line(
        id: String,
        source: MLNSource,
        isSelected: Bool,
        color: RGBColor,
        widths: [Double: Double]
    ) -> MLNLineStyleLayer {
        let layer = MLNLineStyleLayer(identifier: id, source: source)
        layer.predicate = NSPredicate(format: "%K == %@", selectedAttribute, NSNumber(value: isSelected))
        layer.lineColor = NSExpression(forConstantValue: color.uiColor)
        layer.lineWidth = NSExpression(
            forMLNInterpolating: .zoomLevelVariable,
            curveType: .exponential,
            parameters: NSExpression(forConstantValue: 1.5),
            stops: NSExpression(forConstantValue: widths)
        )
        layer.lineCap = NSExpression(forConstantValue: "round")
        layer.lineJoin = NSExpression(forConstantValue: "round")
        return layer
    }

    private static func destinationMarker(source: MLNSource, palette: MapPalette) -> MLNCircleStyleLayer {
        let layer = MLNCircleStyleLayer(identifier: "route-destination", source: source)
        layer.circleRadius = NSExpression(forConstantValue: 9)
        layer.circleColor = NSExpression(forConstantValue: palette.route.uiColor)
        layer.circleStrokeColor = NSExpression(forConstantValue: UIColor.white)
        layer.circleStrokeWidth = NSExpression(forConstantValue: 3)
        return layer
    }
}

extension GeoCoordinate {
    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

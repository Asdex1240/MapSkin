typealias StyleLayer = [String: Any]

enum StyleExpression {
    static func zoomInterpolated(_ stops: [(zoom: Double, value: Double)], base: Double = 1.5) -> [Any] {
        ["interpolate", ["exponential", base], ["zoom"]] + stops.flatMap { [$0.zoom, $0.value] as [Any] }
    }

    static func classIn(_ classes: [String]) -> [Any] {
        ["match", ["get", "class"], classes, true, false]
    }

    static func localizedName(language: String) -> [Any] {
        ["coalesce", ["get", "name:\(language)"], ["get", "name"]]
    }
}

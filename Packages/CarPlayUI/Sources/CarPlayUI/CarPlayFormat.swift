import Foundation

enum CarPlayFormat {
    private static let metersPerMile = 1609.344

    static func displayDistance(
        _ measurement: Measurement<UnitLength>,
        measurementSystem: Locale.MeasurementSystem = Locale.current.measurementSystem
    ) -> Measurement<UnitLength> {
        let meters = measurement.converted(to: .meters).value
        if measurementSystem == .us {
            let miles = meters / metersPerMile
            return miles < 0.1
                ? Measurement(value: (meters * 3.28084 / 10).rounded() * 10, unit: .feet)
                : Measurement(value: rounded(miles), unit: .miles)
        }
        return meters < 1000
            ? Measurement(value: (meters / 10).rounded() * 10, unit: .meters)
            : Measurement(value: rounded(meters / 1000), unit: .kilometers)
    }

    private static func rounded(_ value: Double) -> Double {
        value < 10 ? (value * 10).rounded() / 10 : value.rounded()
    }

    static func distance(_ measurement: Measurement<UnitLength>) -> String {
        measurement.formatted(.measurement(width: .abbreviated, usage: .road))
    }

    static func duration(_ duration: Duration) -> String {
        let rounded = Duration.seconds(max(60, (duration.components.seconds / 60) * 60))
        return rounded.formatted(.units(allowed: [.hours, .minutes], width: .condensedAbbreviated))
    }
}

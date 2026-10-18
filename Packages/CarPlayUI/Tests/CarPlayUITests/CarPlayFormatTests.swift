import Foundation
import Testing
@testable import CarPlayUI

struct CarPlayFormatTests {
    @Test func showsLongMetricDistancesInKilometers() {
        let distance = Measurement(value: 191_699.0, unit: UnitLength.meters)

        let display = CarPlayFormat.displayDistance(distance, measurementSystem: .metric)

        #expect(display.unit == .kilometers)
        #expect(display.value == 192)
    }

    @Test func keepsOneDecimalBelowTenKilometers() {
        let distance = Measurement(value: 2_640.0, unit: UnitLength.meters)

        let display = CarPlayFormat.displayDistance(distance, measurementSystem: .metric)

        #expect(display.unit == .kilometers)
        #expect(display.value == 2.6)
    }

    @Test func roundsShortMetricDistancesToTenMeters() {
        let display = CarPlayFormat.displayDistance(Measurement(value: 283, unit: .meters), measurementSystem: .metric)

        #expect(display.unit == .meters)
        #expect(display.value == 280)
    }

    @Test func usesMilesAndFeetInTheUnitedStates() {
        let long = CarPlayFormat.displayDistance(Measurement(value: 191_699, unit: .meters), measurementSystem: .us)
        let short = CarPlayFormat.displayDistance(Measurement(value: 100, unit: .meters), measurementSystem: .us)

        #expect(long.unit == .miles)
        #expect(long.value == 119)
        #expect(short.unit == .feet)
        #expect(short.value == 330)
    }
}

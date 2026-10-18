import Foundation

enum NavigationFormat {
    static func distance(_ measurement: Measurement<UnitLength>) -> String {
        measurement.formatted(.measurement(width: .abbreviated, usage: .road))
    }

    static func duration(_ duration: Duration) -> String {
        let rounded = Duration.seconds(max(60, (duration.components.seconds / 60) * 60))
        return rounded.formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }

    static func time(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}

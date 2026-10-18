import NavigationCore
import SwiftUI

struct RouteOptionRow: View {
    let route: Route
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: NavigationFormat.duration(route.expectedTravelTime))
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text(details)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.quaternary), lineWidth: 2)
            )
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var details: String {
        let arrival = Date.now.addingTimeInterval(TimeInterval(route.expectedTravelTime.components.seconds))
        let arrivalText = String(localized: "routePreview.arrival \(NavigationFormat.time(arrival))", bundle: .module)
        let via = route.name.isEmpty ? nil : String(localized: "routePreview.via \(route.name)", bundle: .module)
        return [NavigationFormat.distance(route.distance), arrivalText, via]
            .compactMap { $0 }
            .joined(separator: " · ")
    }
}

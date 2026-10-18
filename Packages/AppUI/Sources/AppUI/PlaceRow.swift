import PlaceSearch
import SwiftUI

struct PlaceRow: View {
    let model: HomeModel
    let place: Place
    let symbolName: String

    var body: some View {
        Button {
            Task { await model.planRoute(to: place) }
        } label: {
            PlaceLabel(
                title: Text(verbatim: place.name),
                place: place,
                symbolName: symbolName,
                distance: model.distance(to: place)
            )
        }
        .contextMenu {
            Button {
                model.favorites.save(place, as: .home)
            } label: {
                Label { Text("favorite.action.saveHome", bundle: .module) } icon: { Image(systemName: "house") }
            }
            Button {
                model.favorites.save(place, as: .work)
            } label: {
                Label { Text("favorite.action.saveWork", bundle: .module) } icon: { Image(systemName: "briefcase") }
            }
            Button {
                model.favorites.save(place, as: .custom)
            } label: {
                Label { Text("favorite.action.add", bundle: .module) } icon: { Image(systemName: "star") }
            }
        }
    }
}

struct PlaceLabel: View {
    let title: Text
    let place: Place
    let symbolName: String
    var distance: Measurement<UnitLength>?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbolName)
                .foregroundStyle(.tint)
                .font(.title3)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                title
                    .foregroundStyle(.primary)
                if let address = place.address {
                    Text(verbatim: address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            if let distance {
                Text(verbatim: NavigationFormat.distance(distance))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

import SwiftUI

struct ActiveNavigationView: View {
    let model: HomeModel

    var body: some View {
        if let progress = model.navigation.progress {
            VStack {
                if model.navigation.status != .arrived {
                    ManeuverBanner(
                        progress: progress,
                        status: model.navigation.status,
                        hasRerouteFailure: model.navigation.hasRerouteFailure
                    )
                }
                Spacer()
                if model.navigation.status == .arrived {
                    ArrivalCard(destinationName: model.planning?.place.name) {
                        model.endNavigation()
                    }
                } else {
                    TripSummaryBar(progress: progress) {
                        model.endNavigation()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

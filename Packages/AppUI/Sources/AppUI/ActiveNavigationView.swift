import SwiftUI

struct ActiveNavigationView: View {
    let model: HomeModel
    let onBottomBarHeightChange: (Double) -> Void

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
                Group {
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
                .onGeometryChange(for: Double.self) { $0.size.height } action: { height in
                    onBottomBarHeightChange(height)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

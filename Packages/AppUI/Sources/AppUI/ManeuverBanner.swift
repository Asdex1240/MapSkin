import NavigationCore
import SwiftUI

struct ManeuverBanner: View {
    let progress: NavigationProgress
    let status: NavigationStatus
    let hasRerouteFailure: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            primary
                .padding()
            if let following = progress.followingManeuver, status == .navigating {
                Divider()
                HStack(spacing: 8) {
                    Text("navigation.then", bundle: .module)
                        .font(.subheadline.bold())
                    Image(systemName: following.kind.symbolName)
                        .accessibilityHidden(true)
                    Text(verbatim: following.instruction)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
        .foregroundStyle(.white)
        .background(Color.accentColor.gradient, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var primary: some View {
        if status == .rerouting {
            HStack(spacing: 12) {
                ProgressView()
                    .tint(.white)
                Text("navigation.rerouting", bundle: .module)
                    .font(.title3.bold())
            }
        } else if let maneuver = progress.nextManeuver {
            HStack(spacing: 16) {
                Image(systemName: maneuver.kind.symbolName)
                    .font(.system(.largeTitle, weight: .bold))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: NavigationFormat.distance(progress.distanceToNextManeuver))
                        .font(.title.bold())
                    Text(verbatim: maneuver.instruction)
                        .font(.headline)
                        .lineLimit(2)
                    if hasRerouteFailure {
                        Text("navigation.rerouteFailed", bundle: .module)
                            .font(.footnote)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
}

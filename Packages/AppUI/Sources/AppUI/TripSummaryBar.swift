import NavigationCore
import SwiftUI

struct TripSummaryBar: View {
    let progress: NavigationProgress
    let onEnd: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            metric(
                title: Text("navigation.arrival", bundle: .module),
                value: NavigationFormat.time(progress.estimatedArrival)
            )
            metric(
                title: Text("navigation.remainingTime", bundle: .module),
                value: NavigationFormat.duration(progress.remainingTravelTime)
            )
            metric(
                title: Text("navigation.remainingDistance", bundle: .module),
                value: NavigationFormat.distance(progress.remainingDistance)
            )
            Spacer(minLength: 0)
            Button(role: .destructive, action: onEnd) {
                Text("navigation.end", bundle: .module)
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .controlSize(.large)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func metric(title: Text, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: value)
                .font(.headline)
            title
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

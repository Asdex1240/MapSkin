import NavigationCore
import SwiftUI

struct TripSummaryBar: View {
    let progress: NavigationProgress
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    metrics
                }
                VStack(spacing: 10) {
                    metrics
                }
            }
            endButton
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var metrics: some View {
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
    }

    private var endButton: some View {
        Button(role: .destructive, action: onEnd) {
            Text("navigation.end", bundle: .module)
                .font(.headline)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .tint(.red)
        .controlSize(.large)
    }

    private func metric(title: Text, value: String) -> some View {
        VStack(spacing: 2) {
            Text(verbatim: value)
                .font(.headline)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            title
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

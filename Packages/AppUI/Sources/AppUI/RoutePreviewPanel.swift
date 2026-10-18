import NavigationCore
import SwiftUI

struct RoutePreviewPanel: View {
    let model: HomeModel
    let state: RoutePlanningState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            content
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: state.place.name)
                    .font(.title2.bold())
                if let address = state.place.address {
                    Text(verbatim: address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button {
                model.cancelPlanning()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel(Text("routePreview.close", bundle: .module))
        }
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .loading:
            HStack(spacing: 8) {
                ProgressView()
                Text("routePreview.loading", bundle: .module)
                    .foregroundStyle(.secondary)
            }
        case .failed(let place, let message):
            Text(verbatim: message)
                .foregroundStyle(.secondary)
            Button {
                Task { await model.planRoute(to: place) }
            } label: {
                Text("routePreview.retry", bundle: .module)
            }
            .buttonStyle(.bordered)
        case .ready(let plan):
            routeOptions(plan)
        }
    }

    private func routeOptions(_ plan: RoutePlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(plan.routes) { route in
                RouteOptionRow(route: route, isSelected: route.id == plan.selectedRoute?.id) {
                    model.selectRoute(route.id)
                }
            }
            Button {
                model.startNavigation()
            } label: {
                Text("routePreview.start", bundle: .module)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Label {
                Text("routePreview.safety", bundle: .module)
            } icon: {
                Image(systemName: "exclamationmark.triangle")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }
}

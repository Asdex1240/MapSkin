import SwiftUI

struct MapAttributionLabel: View {
    var body: some View {
        Text("map.attribution", bundle: .module)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.regularMaterial, in: Capsule())
    }
}

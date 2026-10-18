import SwiftUI

struct RecenterButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "location.fill")
                .font(.title2)
                .padding(14)
        }
        .background(.regularMaterial, in: Circle())
        .accessibilityLabel(Text("map.recenter", bundle: .module))
    }
}

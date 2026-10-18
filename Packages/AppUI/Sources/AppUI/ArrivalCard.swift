import SwiftUI

struct ArrivalCard: View {
    let destinationName: String?
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "flag.checkered")
                .font(.largeTitle)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            Text("navigation.arrived.title", bundle: .module)
                .font(.title2.bold())
            if let destinationName {
                Text(verbatim: destinationName)
                    .foregroundStyle(.secondary)
            }
            Button(action: onDone) {
                Text("navigation.arrived.done", bundle: .module)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

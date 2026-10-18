import SwiftUI

struct AboutView: View {
    private static let credits: [(name: String, detail: LocalizedStringKey, url: String)] = [
        ("OpenStreetMap", "about.credits.openStreetMap", "https://www.openstreetmap.org/copyright"),
        ("OpenFreeMap", "about.credits.openFreeMap", "https://openfreemap.org"),
        ("MapLibre", "about.credits.mapLibre", "https://maplibre.org")
    ]

    var body: some View {
        List {
            Section {
                ForEach(Self.credits, id: \.name) { credit in
                    if let url = URL(string: credit.url) {
                        Link(destination: url) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(verbatim: credit.name)
                                    .foregroundStyle(.primary)
                                Text(credit.detail, bundle: .module)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } header: {
                Text("about.credits", bundle: .module)
            }
            Section {
                Text("texturePacks.notice.message", bundle: .module)
            } header: {
                Text("about.texturePacks", bundle: .module)
            }
            Section {
                Text("about.privacy", bundle: .module)
            } header: {
                Text("about.privacy.title", bundle: .module)
            }
            if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                Section {
                    LabeledContent {
                        Text(verbatim: version)
                    } label: {
                        Text("about.version", bundle: .module)
                    }
                }
            }
        }
        .navigationTitle(Text("about.title", bundle: .module))
    }
}

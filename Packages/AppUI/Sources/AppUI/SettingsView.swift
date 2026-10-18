import SwiftUI

struct SettingsView: View {
    let flow: TexturePackImportFlow

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        TexturePacksView(flow: flow)
                    } label: {
                        LabeledContent {
                            Text(verbatim: flow.library.activePack.manifest.name)
                        } label: {
                            Label {
                                Text("settings.textures", bundle: .module)
                            } icon: {
                                Image(systemName: "paintpalette")
                            }
                        }
                    }
                }
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label {
                            Text("about.title", bundle: .module)
                        } icon: {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
            .navigationTitle(Text("settings.title", bundle: .module))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("common.done", bundle: .module)
                    }
                }
            }
        }
        .texturePackImportAlerts(flow, isActive: true)
    }
}

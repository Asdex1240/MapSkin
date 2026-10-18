import SwiftUI
import TexturePacks
import UniformTypeIdentifiers

struct TexturePacksView: View {
    @Bindable var flow: TexturePackImportFlow

    var body: some View {
        List {
            Section {
                ForEach(flow.library.packs) { pack in
                    row(for: pack)
                }
            }
            Section {
                Button {
                    flow.chooseFile()
                } label: {
                    Label {
                        Text("texturePacks.import", bundle: .module)
                    } icon: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
                if let templateURL = flow.templateURL {
                    ShareLink(item: templateURL) {
                        Label {
                            Text("texturePacks.template", bundle: .module)
                        } icon: {
                            Image(systemName: "doc.badge.plus")
                        }
                    }
                }
            } footer: {
                Text("texturePacks.footer", bundle: .module)
            }
        }
        .navigationTitle(Text("settings.textures", bundle: .module))
        .fileImporter(
            isPresented: $flow.isPickerPresented,
            allowedContentTypes: [.mapSkinTexturePack, .zip, .folder]
        ) { result in
            switch result {
            case .success(let url): Task { await flow.importPack(from: url) }
            case .failure(let error): flow.handlePickerFailure(error)
            }
        }
        .task {
            await flow.prepareTemplate()
        }
    }

    private func row(for pack: TexturePack) -> some View {
        Button {
            flow.library.select(pack)
        } label: {
            HStack(spacing: 12) {
                TexturePackPreview(pack: pack)
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: pack.manifest.name)
                        .foregroundStyle(.primary)
                    Text(verbatim: pack.manifest.author)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if pack.id == flow.library.activePackID {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                }
            }
        }
        .accessibilityAddTraits(pack.id == flow.library.activePackID ? .isSelected : [])
        .swipeActions {
            if flow.library.isRemovable(pack) {
                Button(role: .destructive) {
                    flow.delete(pack)
                } label: {
                    Text("texturePacks.delete", bundle: .module)
                }
            }
        }
    }
}

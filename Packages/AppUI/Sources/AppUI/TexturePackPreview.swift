import SwiftUI
import TexturePacks

struct TexturePackPreview: View {
    private static let previewKinds: [TextureKind] = [.grass, .forest, .water, .sand, .urban, .building]

    let pack: TexturePack

    var body: some View {
        Grid(horizontalSpacing: 1, verticalSpacing: 1) {
            GridRow { tiles(Self.previewKinds.prefix(3)) }
            GridRow { tiles(Self.previewKinds.suffix(3)) }
        }
        .frame(width: 66, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .accessibilityHidden(true)
    }

    private func tiles(_ kinds: some Sequence<TextureKind>) -> some View {
        ForEach(Array(kinds), id: \.self) { kind in
            tile(for: kind)
        }
    }

    @ViewBuilder
    private func tile(for kind: TextureKind) -> some View {
        if let url = pack.textureURL(for: kind, appearance: .day),
           let image = UIImage(contentsOfFile: url.path(percentEncoded: false)) {
            Image(uiImage: image)
                .resizable(resizingMode: .tile)
                .interpolation(pack.manifest.filtering == .pixelated ? .none : .medium)
        } else {
            Color.secondary.opacity(0.2)
        }
    }
}

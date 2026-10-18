import MapRendering
import SwiftUI

struct MapSkinRepresentable: UIViewRepresentable {
    let styleURL: URL

    func makeUIView(context: Context) -> MapSkinView {
        MapSkinView(styleURL: styleURL)
    }

    func updateUIView(_ uiView: MapSkinView, context: Context) {}
}

import MapRendering
import MapStyle
import SwiftUI

struct MapSkinRepresentable: UIViewRepresentable {
    let skin: MapSkin
    let recenterRequest: Int
    @Binding var isFollowingUser: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(handledRecenterRequest: recenterRequest)
    }

    func makeUIView(context: Context) -> MapSkinView {
        let view = MapSkinView(skin: skin)
        view.onUserTrackingChange = { isFollowing in
            isFollowingUser = isFollowing
        }
        return view
    }

    func updateUIView(_ uiView: MapSkinView, context: Context) {
        uiView.apply(skin)
        guard context.coordinator.handledRecenterRequest != recenterRequest else { return }
        context.coordinator.handledRecenterRequest = recenterRequest
        uiView.followUserLocation()
    }

    final class Coordinator {
        var handledRecenterRequest: Int

        init(handledRecenterRequest: Int) {
            self.handledRecenterRequest = handledRecenterRequest
        }
    }
}
